package com.jobtracker.demo.repository;

import com.jobtracker.demo.model.ApplicationEvent;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ApplicationEventRepository
        extends MongoRepository<ApplicationEvent, String> {

    /**
     * Returns all events whose applicationId matches.
     * Sorting is applied in the service layer (by eventDate, then createdAt).
     */
    List<ApplicationEvent> findByApplicationId(String applicationId);

    /**
     * Deletes all events belonging to the given application.
     * Called by JobApplicationServiceImpl.delete() for cascade delete.
     */
    void deleteAllByApplicationId(String applicationId);
}
