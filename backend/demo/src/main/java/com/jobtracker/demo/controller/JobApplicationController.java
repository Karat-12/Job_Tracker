package com.jobtracker.demo.controller;

import com.jobtracker.demo.model.JobApplication;
import com.jobtracker.demo.service.JobApplicationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/applications")
@CrossOrigin(origins = "*")
public class JobApplicationController {

    private final JobApplicationService service;

    public JobApplicationController(JobApplicationService service) {
        this.service = service;
    }

    @PostMapping
    public JobApplication create(@RequestBody JobApplication application) {
        return service.save(application);
    }

    @GetMapping
    public List<JobApplication> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public JobApplication getById(@PathVariable String id) {
        return service.getById(id);
    }

    @PutMapping("/{id}")
    public JobApplication update(
            @PathVariable String id,
            @RequestBody JobApplication application) {

        return service.update(id, application);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable String id) {
        service.delete(id);
    }
}