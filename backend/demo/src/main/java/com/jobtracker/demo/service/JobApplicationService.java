package com.jobtracker.demo.service;

import com.jobtracker.demo.model.JobApplication;
import java.util.List;

public interface JobApplicationService {

    JobApplication save(JobApplication application);

    List<JobApplication> getAll();

    JobApplication getById(String id);

    JobApplication update(String id, JobApplication application);

    void delete(String id);
}