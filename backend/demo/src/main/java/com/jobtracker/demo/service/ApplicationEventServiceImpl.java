package com.jobtracker.demo.service;

import com.jobtracker.demo.model.ApplicationEvent;
import com.jobtracker.demo.repository.ApplicationEventRepository;
import com.jobtracker.demo.repository.JobApplicationRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Comparator;
import java.util.List;

@Service
public class ApplicationEventServiceImpl implements ApplicationEventService {

    private static final DateTimeFormatter TIMESTAMP_FMT =
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private final ApplicationEventRepository eventRepository;
    private final JobApplicationRepository applicationRepository;

    public ApplicationEventServiceImpl(
            ApplicationEventRepository eventRepository,
            JobApplicationRepository applicationRepository) {
        this.eventRepository = eventRepository;
        this.applicationRepository = applicationRepository;
    }

    // -------------------------------------------------------------------------
    // Read
    // -------------------------------------------------------------------------

    @Override
    public List<ApplicationEvent> getEventsForApplication(String applicationId) {
        // 404 if the parent application does not exist
        if (!applicationRepository.existsById(applicationId)) {
            throw new RuntimeException("Application not found: " + applicationId);
        }

        List<ApplicationEvent> events = eventRepository.findByApplicationId(applicationId);

        // Sort: primary = eventDate ascending, secondary = createdAt ascending
        events.sort(Comparator
                .comparing(ApplicationEvent::getEventDate,
                        Comparator.nullsLast(Comparator.naturalOrder()))
                .thenComparing(ApplicationEvent::getCreatedAt,
                        Comparator.nullsLast(Comparator.naturalOrder())));

        return events;
    }

    // -------------------------------------------------------------------------
    // Create
    // -------------------------------------------------------------------------

    @Override
    public ApplicationEvent createEvent(String applicationId, ApplicationEvent event) {
        // 404 if the parent application does not exist
        if (!applicationRepository.existsById(applicationId)) {
            throw new RuntimeException("Application not found: " + applicationId);
        }

        validateEventType(event.getEventType());
        validateEventDate(event.getEventDate());

        ApplicationEvent toSave = ApplicationEvent.builder()
                .applicationId(applicationId)
                .eventType(event.getEventType())
                .eventDate(event.getEventDate())
                .notes(event.getNotes())
                .createdAt(now())
                .build();

        return eventRepository.save(toSave);
    }

    // -------------------------------------------------------------------------
    // Update
    // -------------------------------------------------------------------------

    @Override
    public ApplicationEvent updateEvent(String eventId, ApplicationEvent incoming) {
        ApplicationEvent existing = eventRepository.findById(eventId)
                .orElseThrow(() -> new RuntimeException("Event not found: " + eventId));

        validateEventType(incoming.getEventType());
        validateEventDate(incoming.getEventDate());

        // Never touch applicationId or createdAt
        existing.setEventType(incoming.getEventType());
        existing.setEventDate(incoming.getEventDate());
        existing.setNotes(incoming.getNotes());

        return eventRepository.save(existing);
    }

    // -------------------------------------------------------------------------
    // Delete
    // -------------------------------------------------------------------------

    @Override
    public void deleteEvent(String eventId) {
        if (!eventRepository.existsById(eventId)) {
            throw new RuntimeException("Event not found: " + eventId);
        }
        eventRepository.deleteById(eventId);
    }

    @Override
    public void deleteAllEventsForApplication(String applicationId) {
        eventRepository.deleteAllByApplicationId(applicationId);
    }

    // -------------------------------------------------------------------------
    // Migration helper — called from JobApplicationServiceImpl.save()
    // -------------------------------------------------------------------------

    @Override
    public void createAppliedEvent(String applicationId, String dateApplied) {
        ApplicationEvent appliedEvent = ApplicationEvent.builder()
                .applicationId(applicationId)
                .eventType("Applied")
                .eventDate(dateApplied)
                .notes(null)
                .createdAt(now())
                .build();
        eventRepository.save(appliedEvent);
    }

    // -------------------------------------------------------------------------
    // Validation helpers
    // -------------------------------------------------------------------------

    private void validateEventType(String eventType) {
        if (eventType == null || eventType.isBlank()) {
            throw new IllegalArgumentException("eventType is required");
        }
        if (!ApplicationEvent.VALID_EVENT_TYPES.contains(eventType)) {
            throw new IllegalArgumentException(
                    "Invalid eventType: '" + eventType + "'. Must be one of: "
                            + ApplicationEvent.VALID_EVENT_TYPES);
        }
    }

    private void validateEventDate(String eventDate) {
        if (eventDate == null || eventDate.isBlank()) {
            throw new IllegalArgumentException("eventDate is required");
        }
        // Validate format: must be parseable as yyyy-MM-dd
        try {
            java.time.LocalDate.parse(eventDate);
        } catch (Exception e) {
            throw new IllegalArgumentException(
                    "Invalid eventDate format: '" + eventDate + "'. Expected YYYY-MM-DD.");
        }
    }

    private String now() {
        return LocalDateTime.now().format(TIMESTAMP_FMT);
    }
}
