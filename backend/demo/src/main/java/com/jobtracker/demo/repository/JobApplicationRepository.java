package com.jobtracker.demo.repository;

import com.jobtracker.demo.model.JobApplication;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface JobApplicationRepository
        extends MongoRepository<JobApplication, String> {
}