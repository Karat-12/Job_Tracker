package com.jobtracker.demo.service;

import com.jobtracker.demo.model.JobApplication;
import com.jobtracker.demo.repository.JobApplicationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JobApplicationServiceImpl implements JobApplicationService {

    private final JobApplicationRepository repository;

    public JobApplicationServiceImpl(JobApplicationRepository repository) {
        this.repository = repository;
    }

    @Override
    public JobApplication save(JobApplication application) {
        return repository.save(application);
    }

    @Override
    public List<JobApplication> getAll() {
        return repository.findAll();
    }

    @Override
    public JobApplication getById(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Application not found"));
    }

    @Override
    public JobApplication update(String id, JobApplication application) {

        JobApplication existing = getById(id);

        existing.setCompanyName(application.getCompanyName());
        existing.setRole(application.getRole());
        existing.setSource(application.getSource());
        existing.setJobLink(application.getJobLink());
        existing.setDateApplied(application.getDateApplied());
        existing.setStatus(application.getStatus());
        existing.setNotes(application.getNotes());

        return repository.save(existing);
    }

    @Override
    public void delete(String id) {
        repository.deleteById(id);
    }
}