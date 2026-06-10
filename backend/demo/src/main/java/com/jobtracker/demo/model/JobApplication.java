package com.jobtracker.demo.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.ArrayList;
import java.util.List;

@Document(collection = "applications")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class JobApplication {

    @Id
    private String id;

    private String companyName;

    private String role;

    private String source;

    private String jobLink;

    /** ISO date string, e.g. "2026-06-08" */
    private String dateApplied;

    /**
     * Current status. Valid values:
     * Applied | OA Scheduled | OA Completed |
     * Interview Scheduled | Interview Completed | Offer | Rejected
     */
    private String status;

    private String notes;

    /**
     * ID of the Resume document used for this application.
     * Null when no resume is linked.
     */
    private String resumeId;

    /**
     * Ordered list of status-change events.
     * Never cleared — only appended to.
     * Initialised to empty list so Mongo never stores null.
     */
    @Builder.Default
    private List<TimelineEvent> timeline = new ArrayList<>();
}
