package com.jobtracker.demo.service;

import com.jobtracker.demo.model.ApplicationEvent;

import java.util.List;

public interface ApplicationEventService {

    /**
     * Returns all events for the given application, sorted by eventDate ascending,
     * with createdAt as a secondary sort key.
     *
     * @throws RuntimeException (404) if no application with applicationId exists.
     */
    List<ApplicationEvent> getEventsForApplication(String applicationId);

    /**
     * Creates a new event linked to applicationId.
     * Sets createdAt server-side. Validates eventType against the allowed list.
     *
     * @throws IllegalArgumentException (400) for invalid eventType or missing/malformed eventDate.
     * @throws RuntimeException         (404) if applicationId does not exist.
     */
    ApplicationEvent createEvent(String applicationId, ApplicationEvent event);

    /**
     * Updates eventType, eventDate, and/or notes for an existing event.
     * Never modifies applicationId or createdAt.
     *
     * @throws IllegalArgumentException (400) for invalid eventType or malformed eventDate.
     * @throws RuntimeException         (404) if eventId does not exist.
     */
    ApplicationEvent updateEvent(String eventId, ApplicationEvent incoming);

    /**
     * Deletes a single event by its own ID.
     *
     * @throws RuntimeException (404) if eventId does not exist.
     */
    void deleteEvent(String eventId);

    /**
     * Deletes all events belonging to the given application.
     * Called during cascade delete of the parent JobApplication.
     */
    void deleteAllEventsForApplication(String applicationId);

    /**
     * Auto-creates the initial "Applied" event when a new application is saved.
     *
     * @param applicationId the newly created application's ID
     * @param dateApplied   ISO date string "YYYY-MM-DD"
     */
    void createAppliedEvent(String applicationId, String dateApplied);
}
