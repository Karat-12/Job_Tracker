package com.jobtracker.demo.service;

import com.jobtracker.demo.model.Resume;
import com.jobtracker.demo.repository.ResumeRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
public class ResumeServiceImpl implements ResumeService {

    /** Local directory where PDF files are stored. Configurable via application.properties. */
    @Value("${resume.upload.dir:uploads/resumes}")
    private String uploadDir;

    private final ResumeRepository repository;

    public ResumeServiceImpl(ResumeRepository repository) {
        this.repository = repository;
    }

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    @Override
    public Resume upload(String name, String notes, MultipartFile file) throws IOException {
        ensureUploadDirExists();

        // Generate a unique filename to avoid collisions
        String originalFilename = file.getOriginalFilename() != null
                ? file.getOriginalFilename()
                : "resume.pdf";
        String storedFileName = UUID.randomUUID() + "_" + originalFilename;

        Path dest = Paths.get(uploadDir, storedFileName);
        Files.write(dest, file.getBytes());

        Resume resume = Resume.builder()
                .name(name != null ? name : originalFilename)
                .fileName(storedFileName)
                .uploadDate(LocalDate.now().toString())
                .notes(notes)
                .build();

        return repository.save(resume);
    }

    @Override
    public List<Resume> getAll() {
        return repository.findAll();
    }

    @Override
    public Resume getById(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Resume not found: " + id));
    }

    @Override
    public Resume update(String id, String name, String notes) {
        Resume existing = getById(id);
        if (name != null && !name.isBlank()) {
            existing.setName(name);
        }
        existing.setNotes(notes);
        return repository.save(existing);
    }

    @Override
    public void delete(String id) throws IOException {
        Resume resume = getById(id);

        // Delete the file from disk
        Path filePath = Paths.get(uploadDir, resume.getFileName());
        Files.deleteIfExists(filePath);

        repository.deleteById(id);
    }

    @Override
    public String getFilePath(String fileName) {
        return Paths.get(uploadDir, fileName).toAbsolutePath().toString();
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    private void ensureUploadDirExists() throws IOException {
        Path dir = Paths.get(uploadDir);
        if (!Files.exists(dir)) {
            Files.createDirectories(dir);
        }
    }
}
