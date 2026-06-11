package com.jobtracker.demo.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.index.Indexed;

import java.util.List;

/**
 * A first-class recruitment event belonging to one JobApplication.
 * Stored in the "application_events" collection — completely separate
 * from the embedded timeline array inside JobApplication.
 */
@Document(collection = "application_events")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApplicationEvent {

    /** Valid eventType values. */
    public static final List<String> VALID_EVENT_TYPES = List.of(
            "Applied",
            "OA Scheduled",
            "OA Completed",
            "Interview Scheduled",
            "Interview Completed",
            "HR Round Scheduled",
            "HR Round Completed",
            "Offer Received",
            "Offer Accepted",
            "Rejected",
            "Joined"
    );

    @Id
    private String id;

    /** FK → JobApplication.id */
    @Indexed
    private String applicationId;

    /**
     * Category of recruitment milestone.
     * Must be one of VALID_EVENT_TYPES.
     */
    private String eventType;

    /**
     * Real-world date the event occurred or is scheduled, e.g. "2026-06-20".
     * ISO date string "YYYY-MM-DD". May be in the future for scheduled events.
     */
    private String eventDate;

    /** Optional free-text notes. Null when not provided. */
    private String notes;

    /**
     * Server-set ISO-8601 datetime string, e.g. "2026-06-20T14:30:00".
     * Never supplied by the client — always set by ApplicationEventServiceImpl.
     */
    private String createdAt;
}
