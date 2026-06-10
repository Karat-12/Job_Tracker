package com.jobtracker.demo.service;

import com.jobtracker.demo.model.JobApplication;
import com.jobtracker.demo.model.TimelineEvent;
import com.jobtracker.demo.repository.JobApplicationRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class JobApplicationServiceImpl implements JobApplicationService {

    private static final DateTimeFormatter TIMESTAMP_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    /** Date-only formatter used to convert dateApplied into a timeline timestamp. */
    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final JobApplicationRepository repository;

    public JobApplicationServiceImpl(JobApplicationRepository repository) {
        this.repository = repository;
    }

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    @Override
    public JobApplication save(JobApplication application) {
        // Ensure the timeline list is never null
        if (application.getTimeline() == null) {
            application.setTimeline(new ArrayList<>());
        }

        // Seed the initial "Applied" event for brand-new applications.
        // Use the dateApplied field as the timestamp so the first entry
        // reflects when the application was actually sent, not server time.
        if (application.getId() == null || application.getId().isEmpty()) {
            String appliedTimestamp = toTimestamp(application.getDateApplied());
            application.getTimeline().add(
                    TimelineEvent.builder()
                            .title("Applied")
                            .description("Application submitted")
                            .timestamp(appliedTimestamp)
                            .build()
            );
            // If the user created the application with a status other than
            // "Applied" (e.g. already at "OA Completed"), also seed that event.
            if (application.getStatus() != null
                    && !application.getStatus().equals("Applied")) {
                application.getTimeline().add(buildEvent(application.getStatus()));
            }
        }

        return repository.save(application);
    }

    @Override
    public List<JobApplication> getAll() {
        List<JobApplication> all = repository.findAll();
        // Migrate any documents that pre-date the timeline feature
        all.forEach(this::migrateTimelineIfEmpty);
        return all;
    }

    @Override
    public JobApplication getById(String id) {
        JobApplication app = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Application not found: " + id));
        migrateTimelineIfEmpty(app);
        return app;
    }

    @Override
    public JobApplication update(String id, JobApplication incoming) {
        JobApplication existing = getById(id); // already migrated

        String oldStatus = existing.getStatus();
        String newStatus = incoming.getStatus();

        // Guard: timeline must never be null on existing doc
        if (existing.getTimeline() == null) {
            existing.setTimeline(new ArrayList<>());
        }

        // Append a new event only when the status actually changes
        if (newStatus != null && !newStatus.equals(oldStatus)) {
            existing.getTimeline().add(buildEvent(newStatus));
        }

        // Update all scalar fields — timeline is intentionally NOT touched
        // beyond the append above; the client copy is always ignored.
        existing.setCompanyName(incoming.getCompanyName());
        existing.setRole(incoming.getRole());
        existing.setSource(incoming.getSource());
        existing.setJobLink(incoming.getJobLink());
        existing.setDateApplied(incoming.getDateApplied());
        existing.setStatus(newStatus);
        existing.setNotes(incoming.getNotes());
        existing.setResumeId(incoming.getResumeId());

        return repository.save(existing);
    }

    @Override
    public void delete(String id) {
        repository.deleteById(id);
    }

    // -------------------------------------------------------------------------
    // Migration
    // -------------------------------------------------------------------------

    /**
     * For documents that existed before the timeline feature was introduced
     * (i.e. their timeline list is null or empty), synthesise a minimal history:
     *
     *   1. "Applied"  — dated with dateApplied
     *   2. current status (if it differs from "Applied") — dated now
     *
     * This is applied in-memory on read so the Flutter UI always sees a
     * non-empty timeline. The document is also persisted so future reads
     * are instant (no repeated synthesis).
     */
    private void migrateTimelineIfEmpty(JobApplication app) {
        if (app.getTimeline() != null && !app.getTimeline().isEmpty()) {
            return; // already has history — nothing to do
        }

        List<TimelineEvent> migrated = new ArrayList<>();
        String appliedTimestamp = toTimestamp(app.getDateApplied());

        // Event 1 — Applied (uses dateApplied as timestamp)
        migrated.add(TimelineEvent.builder()
                .title("Applied")
                .description("Application submitted")
                .timestamp(appliedTimestamp)
                .build());

        // Event 2 — current status (only if different from Applied)
        if (app.getStatus() != null && !app.getStatus().equals("Applied")) {
            migrated.add(TimelineEvent.builder()
                    .title(app.getStatus())
                    .description("Status set to " + app.getStatus())
                    .timestamp(LocalDateTime.now().format(TIMESTAMP_FMT))
                    .build());
        }

        app.setTimeline(migrated);
        // Persist so the migration runs only once per document
        repository.save(app);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private TimelineEvent buildEvent(String status) {
        return TimelineEvent.builder()
                .title(status)
                .description("Status set to " + status)
                .timestamp(LocalDateTime.now().format(TIMESTAMP_FMT))
                .build();
    }

    /**
     * Converts a dateApplied string ("yyyy-MM-dd") to a full timestamp string.
     * Falls back to "now" if the string is null or unparseable.
     */
    private String toTimestamp(String dateApplied) {
        if (dateApplied == null || dateApplied.isBlank()) {
            return LocalDateTime.now().format(TIMESTAMP_FMT);
        }
        try {
            // Parse as a date, use start-of-day as the time component
            LocalDate date = LocalDate.parse(dateApplied, DATE_FMT);
            return date.atStartOfDay().format(TIMESTAMP_FMT);
        } catch (Exception e) {
            return LocalDateTime.now().format(TIMESTAMP_FMT);
        }
    }
}
