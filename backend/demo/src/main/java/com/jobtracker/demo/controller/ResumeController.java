package com.jobtracker.demo.controller;

import com.jobtracker.demo.model.Resume;
import com.jobtracker.demo.service.ResumeService;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

/**
 * REST controller for Resume CRUD and file serving.
 *
 * Endpoints:
 *   POST   /api/resumes/upload          — upload PDF + metadata
 *   GET    /api/resumes                 — list all resumes
 *   GET    /api/resumes/{id}            — get one resume metadata
 *   PUT    /api/resumes/{id}            — update name/notes
 *   DELETE /api/resumes/{id}            — delete metadata + file
 *   GET    /api/resumes/{id}/file       — stream the PDF file
 */
@RestController
@RequestMapping("/api/resumes")
@CrossOrigin(origins = "*")
public class ResumeController {

    private final ResumeService resumeService;

    public ResumeController(ResumeService resumeService) {
        this.resumeService = resumeService;
    }

    /** Upload a new resume PDF with metadata. */
    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public Resume upload(
            @RequestParam("name") String name,
            @RequestParam(value = "notes", required = false) String notes,
            @RequestParam("file") MultipartFile file) throws IOException {

        return resumeService.upload(name, notes, file);
    }

    /** List all resume metadata documents. */
    @GetMapping
    public List<Resume> getAll() {
        return resumeService.getAll();
    }

    /** Get a single resume's metadata. */
    @GetMapping("/{id}")
    public Resume getById(@PathVariable String id) {
        return resumeService.getById(id);
    }

    /** Update name and/or notes for an existing resume (no file replacement). */
    @PutMapping("/{id}")
    public Resume update(
            @PathVariable String id,
            @RequestParam("name") String name,
            @RequestParam(value = "notes", required = false) String notes) {

        return resumeService.update(id, name, notes);
    }

    /** Delete the resume metadata from MongoDB and the PDF from disk. */
    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) throws IOException {
        resumeService.delete(id);
    }

    /** Stream the PDF file so the frontend can display / download it. */
    @GetMapping("/{id}/file")
    public ResponseEntity<Resource> getFile(@PathVariable String id) {
        Resume resume = resumeService.getById(id);
        String filePath = resumeService.getFilePath(resume.getFileName());

        Resource resource = new FileSystemResource(filePath);
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_PDF)
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "inline; filename=\"" + resume.getFileName() + "\"")
                .body(resource);
    }
}
