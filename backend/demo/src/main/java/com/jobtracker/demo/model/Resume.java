package com.jobtracker.demo.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

/**
 * Metadata for an uploaded resume PDF.
 * The actual file is stored on the local filesystem under /uploads/resumes/.
 */
@Document(collection = "resumes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Resume {

    @Id
    private String id;

    /** User-facing label, e.g. "SDE Resume v3" */
    private String name;

    /** Stored filename on disk, e.g. "uuid-sde-resume-v3.pdf" */
    private String fileName;

    /** ISO-8601 date string of when the file was uploaded */
    private String uploadDate;

    /** Optional notes about this resume version */
    private String notes;
}
