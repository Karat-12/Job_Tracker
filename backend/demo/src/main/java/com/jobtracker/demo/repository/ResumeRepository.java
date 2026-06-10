package com.jobtracker.demo.repository;

import com.jobtracker.demo.model.Resume;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ResumeRepository extends MongoRepository<Resume, String> {
}
