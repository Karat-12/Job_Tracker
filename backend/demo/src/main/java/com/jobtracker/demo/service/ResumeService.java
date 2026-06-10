package com.jobtracker.demo.service;

import com.jobtracker.demo.model.Resume;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

public interface ResumeService {

    /** Save resume metadata and persist the PDF file to disk. */
    Resume upload(String name, String notes, MultipartFile file) throws IOException;

    List<Resume> getAll();

    Resume getById(String id);

    /** Update name / notes only — file is not replaced. */
    Resume update(String id, String name, String notes);

    void delete(String id) throws IOException;

    /** Returns the absolute path on disk for the given resume's file. */
    String getFilePath(String fileName);
}
