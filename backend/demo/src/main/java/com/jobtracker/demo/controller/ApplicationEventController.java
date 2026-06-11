package com.jobtracker.demo.controller;

import com.jobtracker.demo.model.ApplicationEvent;
import com.jobtracker.demo.service.ApplicationEventService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * REST endpoints for ApplicationEvent CRUD.
 *
 * List / create: scoped under the parent application
 *   GET    /api/applications/{applicationId}/events
 *   POST   /api/applications/{applicationId}/events
 *
 * Update / delete: top-level by event ID
 *   PUT    /api/events/{eventId}
 *   DELETE /api/events/{eventId}
 */
@RestController
@CrossOrigin(origins = "*")
public class ApplicationEventController {

    private final ApplicationEventService eventService;

    public ApplicationEventController(ApplicationEventService eventService) {
        this.eventService = eventService;
    }

    // -------------------------------------------------------------------------
    // GET /api/applications/{applicationId}/events
    // -------------------------------------------------------------------------

    @GetMapping("/api/applications/{applicationId}/events")
    public ResponseEntity<?> getEvents(@PathVariable String applicationId) {
        try {
            List<ApplicationEvent> events =
                    eventService.getEventsForApplication(applicationId);
            return ResponseEntity.ok(events);
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(e.getMessage());
        }
    }

    // -------------------------------------------------------------------------
    // POST /api/applications/{applicationId}/events
    // -------------------------------------------------------------------------

    @PostMapping("/api/applications/{applicationId}/events")
    public ResponseEntity<?> createEvent(
            @PathVariable String applicationId,
            @RequestBody ApplicationEvent event) {
        try {
            ApplicationEvent created = eventService.createEvent(applicationId, event);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(e.getMessage());
        }
    }

    // -------------------------------------------------------------------------
    // PUT /api/events/{eventId}
    // -------------------------------------------------------------------------

    @PutMapping("/api/events/{eventId}")
    public ResponseEntity<?> updateEvent(
            @PathVariable String eventId,
            @RequestBody ApplicationEvent event) {
        try {
            ApplicationEvent updated = eventService.updateEvent(eventId, event);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(e.getMessage());
        }
    }

    // -------------------------------------------------------------------------
    // DELETE /api/events/{eventId}
    // -------------------------------------------------------------------------

    @DeleteMapping("/api/events/{eventId}")
    public ResponseEntity<?> deleteEvent(@PathVariable String eventId) {
        try {
            eventService.deleteEvent(eventId);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            if (e.getMessage() != null && e.getMessage().contains("not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(e.getMessage());
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(e.getMessage());
        }
    }
}
