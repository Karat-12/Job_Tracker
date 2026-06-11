package com.jobtracker.demo.service;

import com.jobtracker.demo.model.JobApplication;
import com.jobtracker.demo.model.TimelineEvent;
import com.jobtracker.demo.repository.JobApplicationRepository;
import org.springframework.context.annotation.Lazy;
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

    private static final DateTimeFormatter DATE_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private final JobApplicationRepository repository;
    private final ApplicationEventService applicationEventService;

    public JobApplicationServiceImpl(
            JobApplicationRepository repository,
            // @Lazy breaks the potential circular dependency that can arise
            // if ApplicationEventServiceImpl ever needs JobApplicationService.
            @Lazy ApplicationEventService applicationEventService) {
        this.repository = repository;
        this.applicationEventService = applicationEventService;
    }

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    @Override
    public JobApplication save(JobApplication application) {
        // Ensure the legacy embedded timeline list is never null
        if (application.getTimeline() == null) {
            application.setTimeline(new ArrayList<>());
        }

        // Seed the legacy embedded "Applied" event for brand-new applications
        // (kept for backward-compat with existing documents).
        if (application.getId() == null || application.getId().isEmpty()) {
            String appliedTimestamp = toTimestamp(application.getDateApplied());
            application.getTimeline().add(
                    TimelineEvent.builder()
                            .title("Applied")
                            .description("Application submitted")
                            .timestamp(appliedTimestamp)
                            .build()
            );
            if (application.getStatus() != null
                    && !application.getStatus().equals("Applied")) {
                application.getTimeline().add(buildEvent(application.getStatus()));
            }
        }

        JobApplication saved = repository.save(application);

        // REQ-2.5 — auto-create the "Applied" ApplicationEvent in the new collection
        if (application.getId() == null || application.getId().isEmpty()
                || saved.getId() != null) {
            // Only for new documents (id was blank before save, now assigned)
            boolean wasNew = (application.getId() == null || application.getId().isEmpty());
            if (wasNew) {
                applicationEventService.createAppliedEvent(
                        saved.getId(), saved.getDateApplied());
            }
        }

        return saved;
    }

    @Override
    public List<JobApplication> getAll() {
        List<JobApplication> all = repository.findAll();
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
        JobApplication existing = getById(id);

        String oldStatus = existing.getStatus();
        String newStatus = incoming.getStatus();

        if (existing.getTimeline() == null) {
            existing.setTimeline(new ArrayList<>());
        }

        // Append to the legacy embedded timeline on status change
        if (newStatus != null && !newStatus.equals(oldStatus)) {
            existing.getTimeline().add(buildEvent(newStatus));
        }

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
        // REQ-2.6 — cascade delete all ApplicationEvents first
        applicationEventService.deleteAllEventsForApplication(id);
        repository.deleteById(id);
    }

    // -------------------------------------------------------------------------
    // Legacy migration
    // -------------------------------------------------------------------------

    private void migrateTimelineIfEmpty(JobApplication app) {
        if (app.getTimeline() != null && !app.getTimeline().isEmpty()) {
            return;
        }

        List<TimelineEvent> migrated = new ArrayList<>();
        String appliedTimestamp = toTimestamp(app.getDateApplied());

        migrated.add(TimelineEvent.builder()
                .title("Applied")
                .description("Application submitted")
                .timestamp(appliedTimestamp)
                .build());

        if (app.getStatus() != null && !app.getStatus().equals("Applied")) {
            migrated.add(TimelineEvent.builder()
                    .title(app.getStatus())
                    .description("Status set to " + app.getStatus())
                    .timestamp(LocalDateTime.now().format(TIMESTAMP_FMT))
                    .build());
        }

        app.setTimeline(migrated);
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

    private String toTimestamp(String dateApplied) {
        if (dateApplied == null || dateApplied.isBlank()) {
            return LocalDateTime.now().format(TIMESTAMP_FMT);
        }
        try {
            LocalDate date = LocalDate.parse(dateApplied, DATE_FMT);
            return date.atStartOfDay().format(TIMESTAMP_FMT);
        } catch (Exception e) {
            return LocalDateTime.now().format(TIMESTAMP_FMT);
        }
    }
}
