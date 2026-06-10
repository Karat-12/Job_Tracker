package com.jobtracker.demo.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * An immutable record of a single status transition in an application's history.
 * Stored as an embedded array inside JobApplication — no separate collection needed.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TimelineEvent {

    /** Human-readable title, e.g. "OA Completed" */
    private String title;

    /** Optional extra detail, e.g. "Status changed from OA Scheduled" */
    private String description;

    /** ISO-8601 timestamp string, e.g. "2026-06-10T14:30:00" */
    private String timestamp;
}
