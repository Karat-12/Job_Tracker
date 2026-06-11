# Requirements Document

## Introduction

This document specifies the requirements for replacing the current status-driven timeline in the Job Tracker application with a first-class `ApplicationEvent` entity system.

### Purpose

The current timeline is generated automatically from `JobApplication.status` changes. It cannot represent future scheduled events (e.g., "Interview Scheduled on 5 Jul 2026") and cannot be manually edited. This redesign introduces a separate `ApplicationEvent` collection that users control directly, while keeping the existing `status` field fully intact for Kanban, filtering, and dashboard use.

### Scope

- New MongoDB collection: `application_events`
- New Spring Boot: entity, repository, service, controller
- New Flutter: model, API methods, Add/Edit dialog, updated details screen timeline
- Migration: auto-create an "Applied" event when a new application is saved
- Cascade delete: events are removed when their parent application is deleted

### Out of Scope

Home screen, Kanban, list cards, dashboard metrics, Resume Library, AddApplicationScreen, authentication, notifications, analytics, and any changes to `JobApplication.status` semantics.

---

## Overview

Replace the current status-driven timeline with a first-class `ApplicationEvent` entity system. Events are user-managed, stored independently from the `JobApplication` status, sorted by their actual date, and displayed as a chronological audit log on the Application Details screen. The existing `status` field on `JobApplication` is preserved for filtering, Kanban, and dashboard use.

---

## Background: What Exists Today

### Backend
- `JobApplication` MongoDB document (`applications` collection) contains an embedded `List<TimelineEvent> timeline` array.
- `TimelineEvent` is an embedded Java class with `title`, `description`, and `timestamp` (ISO-8601 string, server-generated at status-change time).
- `JobApplicationServiceImpl.update()` auto-appends to this embedded list whenever `status` changes. The client cannot write to `timeline` directly.
- `JobApplicationServiceImpl.migrateTimelineIfEmpty()` synthesises two events on first read for legacy documents.
- No separate events collection exists today.

### Frontend
- `Application` Dart model contains `List<TimelineEvent> timeline` (read-only from the server).
- `TimelineEvent` Dart model has `title`, `description`, `timestamp` (string), and a `dateTime` computed getter.
- `ApplicationTimeline` widget renders the embedded list; falls back to a single node if the list is empty.
- `ApplicationDetailsScreen` shows `ApplicationTimeline(timeline: _application.timeline, ...)` inside a `Card`.
- No "Add Event" UI exists anywhere in the codebase.

---

## Requirements

### REQ-1 — ApplicationEvent Data Model

**REQ-1.1** Create a new MongoDB collection `application_events` with the document structure:

| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | String | Yes | MongoDB `@Id`, auto-generated |
| `applicationId` | String | Yes | References `JobApplication.id` |
| `eventType` | String | Yes | One of the defined event types (see REQ-1.2) |
| `eventDate` | String | Yes | ISO date string `"YYYY-MM-DD"` — the real-world date the event occurred or is scheduled |
| `notes` | String | No | Free-text user notes about this event |
| `createdAt` | String | Yes | ISO-8601 datetime string set server-side at creation time; never client-supplied |

**REQ-1.2** The valid `eventType` values are exactly:

```
Applied
OA Scheduled
OA Completed
Interview Scheduled
Interview Completed
HR Round Scheduled
HR Round Completed
Offer Received
Offer Accepted
Rejected
Joined
```

No other values are accepted. The backend must reject unknown `eventType` values with HTTP 400.

**REQ-1.3** `eventDate` is independent of `createdAt`. A user may record a past event (e.g., "OA Completed" with `eventDate = 2026-06-10`) or a future scheduled event (e.g., "Interview Scheduled" with `eventDate = 2026-07-05`).

**REQ-1.4** The existing `JobApplication` document is not modified by this feature. The embedded `List<TimelineEvent> timeline` field and `TimelineEvent` Java class remain in place; the migration logic in `JobApplicationServiceImpl` continues to function as-is for any existing data that still uses it.

---

### REQ-2 — Backend API Endpoints

**REQ-2.1 — List events for an application**
```
GET /api/applications/{applicationId}/events
```
- Returns all `ApplicationEvent` documents where `applicationId` matches the path variable.
- Results are sorted by `eventDate` ascending (oldest first). If two events share the same `eventDate`, they are secondarily sorted by `createdAt` ascending.
- Returns HTTP 200 with a JSON array (empty array if none exist).
- Returns HTTP 404 if the referenced `applicationId` does not exist in the `applications` collection.

**REQ-2.2 — Create an event**
```
POST /api/applications/{applicationId}/events
```
- Request body: `{ "eventType": "...", "eventDate": "YYYY-MM-DD", "notes": "..." }`
- `eventType` and `eventDate` are required. `notes` is optional.
- `applicationId` is taken from the path, not the request body.
- `createdAt` is set server-side to the current UTC datetime; the client must not supply it.
- Returns HTTP 201 with the created `ApplicationEvent` document including its generated `id`.
- Returns HTTP 400 if `eventType` is not one of the defined values, or if `eventDate` is missing or malformed.
- Returns HTTP 404 if the referenced `applicationId` does not exist.

**REQ-2.3 — Update an event**
```
PUT /api/events/{eventId}
```
- Request body: `{ "eventType": "...", "eventDate": "YYYY-MM-DD", "notes": "..." }`
- All three fields may be updated. `applicationId` and `createdAt` are never modified.
- Returns HTTP 200 with the updated document.
- Returns HTTP 400 for invalid `eventType` or malformed `eventDate`.
- Returns HTTP 404 if `eventId` does not exist.

**REQ-2.4 — Delete an event**
```
DELETE /api/events/{eventId}
```
- Returns HTTP 204 on success.
- Returns HTTP 404 if `eventId` does not exist.
- Deleting an event never affects the parent `JobApplication` document or its status.

**REQ-2.5 — Data migration on application creation**

When `POST /api/applications` creates a new `JobApplication`, the backend automatically creates one `ApplicationEvent`:
- `eventType`: `"Applied"`
- `eventDate`: the value of the `JobApplication.dateApplied` field
- `notes`: `null`
- `createdAt`: current server time

This runs inside the same `JobApplicationServiceImpl.save()` method. No manual migration step is needed for new documents.

**REQ-2.6 — Cascade delete**

When `DELETE /api/applications/{id}` is called, all `ApplicationEvent` documents with `applicationId == id` are deleted before the `JobApplication` is deleted. No orphan event documents may remain.

---

### REQ-3 — Backend Implementation Structure

**REQ-3.1** Create `ApplicationEvent.java` in `com.jobtracker.demo.model` as a `@Document(collection = "application_events")` class using Lombok `@Data @NoArgsConstructor @AllArgsConstructor @Builder`.

**REQ-3.2** Create `ApplicationEventRepository.java` in `com.jobtracker.demo.repository` extending `MongoRepository<ApplicationEvent, String>`. Add a method `List<ApplicationEvent> findByApplicationId(String applicationId)` for the service layer.

**REQ-3.3** Create `ApplicationEventService.java` interface and `ApplicationEventServiceImpl.java` implementation in `com.jobtracker.demo.service`.

**REQ-3.4** Create `ApplicationEventController.java` in `com.jobtracker.demo.controller` with routes as defined in REQ-2.

**REQ-3.5** Update `JobApplicationServiceImpl.save()` to call `applicationEventService.createAppliedEvent(applicationId, dateApplied)` after persisting the new `JobApplication`.

**REQ-3.6** Update `JobApplicationServiceImpl.delete()` to call `applicationEventRepository.deleteAllByApplicationId(id)` before `repository.deleteById(id)`. Add a `deleteAllByApplicationId(String applicationId)` derived query method to `ApplicationEventRepository`.

---

### REQ-4 — Frontend Dart Model

**REQ-4.1** Create `lib/models/application_event.dart` with a Dart class `ApplicationEvent`:

| Field | Dart type | Notes |
|---|---|---|
| `id` | `String` | |
| `applicationId` | `String` | |
| `eventType` | `String` | |
| `eventDate` | `String` | ISO date `"YYYY-MM-DD"` — kept as String for round-tripping; parsed to `DateTime` via a getter |
| `notes` | `String?` | |
| `createdAt` | `String` | ISO-8601 datetime string |

- Implement `fromJson`, `toJson`, `copyWith`.
- Add a `DateTime? get eventDateTime` computed getter that parses `eventDate` as a `DateTime` (returns `null` on parse failure).

**REQ-4.2** Add a static constant list `AppConstants.eventTypes` in `lib/utils/constants.dart` containing the 11 valid event type strings from REQ-1.2, in the order listed there.

**REQ-4.3** Add `AppConstants.getEventTypeIcon(String eventType)` returning an appropriate `IconData` per event type. Reuse existing icons from `getStatusIcon` where the event type matches an existing status string. New icons:

| Event Type | Icon |
|---|---|
| HR Round Scheduled | `Icons.groups` |
| HR Round Completed | `Icons.groups_3` |
| Offer Received | `Icons.card_giftcard` |
| Offer Accepted | `Icons.check_circle` |
| Joined | `Icons.work` |

**REQ-4.4** Add `AppConstants.getEventTypeColor(String eventType)` returning a `Color`. Reuse `getStatusColor` for event types that match existing status strings. New mappings:

| Event Type | Color |
|---|---|
| HR Round Scheduled | `Colors.cyan` |
| HR Round Completed | `Colors.teal` |
| Offer Received | `Colors.lightGreen` |
| Offer Accepted | `Colors.green` |
| Joined | `Colors.indigo` |

---

### REQ-5 — Frontend API Service

**REQ-5.1** Add the following static methods to `ApiService` in `lib/services/api_service.dart`:

```dart
static Future<List<ApplicationEvent>> getEvents(String applicationId)
static Future<ApplicationEvent> createEvent(String applicationId, ApplicationEvent event)
static Future<ApplicationEvent> updateEvent(String eventId, ApplicationEvent event)
static Future<void> deleteEvent(String eventId)
```

**REQ-5.2** All four methods must follow the exact same error-handling pattern already established in `ApiService`: `SocketException` → `'Unable to connect to server'`, `TimeoutException` → `'Unable to connect to server'`, HTTP non-success → specific message, catch-all → specific message.

**REQ-5.3** `createEvent` must strip `id` and `createdAt` from the JSON payload sent to the server, since both are server-generated.

---

### REQ-6 — Application Details Screen

**REQ-6.1** The Timeline section in `ApplicationDetailsScreen` must be refactored to load `ApplicationEvent` records from the API instead of reading from `_application.timeline`.

**REQ-6.2** `ApplicationDetailsScreen` must load events by calling `ApiService.getEvents(_application.id)` in `initState`. The loaded list is stored in `List<ApplicationEvent> _events`.

**REQ-6.3** A loading spinner is displayed in place of the timeline while events are being fetched.

**REQ-6.4** The Timeline card must show an "Add Event" button (using `TextButton.icon` with `Icons.add`) in its header row, aligned to the right of the "Timeline" title text.

**REQ-6.5** Tapping "Add Event" opens `AddEventDialog` (see REQ-7). On successful creation, the new event is appended to `_events` and the list is re-sorted by `eventDate` ascending.

**REQ-6.6** Each event row in the timeline must show:
- The event's colour-coded dot and vertical connector line (existing visual pattern from `ApplicationTimeline` widget).
- The `eventType` as the title, in the event type's colour.
- The formatted `eventDate` below the title (using `DateFormatUtil.formatDate`).
- An optional `notes` line if `notes` is non-null and non-empty.
- An edit icon button (pencil, small) and a delete icon button (trash, small, error colour) on the right side of each event row.

**REQ-6.7** Tapping the edit icon opens `AddEventDialog` in edit mode pre-populated with the event's current values. On save, the updated event replaces the old one in `_events` and the list is re-sorted.

**REQ-6.8** Tapping the delete icon shows a confirmation `AlertDialog` with the event type name. On confirm, `ApiService.deleteEvent(event.id)` is called and the event is removed from `_events`. A SnackBar confirms deletion.

**REQ-6.9** The existing `ApplicationTimeline` widget (which renders `List<TimelineEvent>`) is replaced in `ApplicationDetailsScreen` with direct inline rendering using `_events`. The `ApplicationTimeline` widget file itself may remain but is no longer used in the details screen.

**REQ-6.10** The `Application` Dart model retains its `timeline` field for backward compatibility; however, `ApplicationDetailsScreen` no longer reads from it for display purposes.

---

### REQ-7 — Add / Edit Event Dialog

**REQ-7.1** Create `lib/widgets/add_event_dialog.dart` implementing `AddEventDialog` as a `StatefulWidget` dialog.

**REQ-7.2** `AddEventDialog` accepts optional `ApplicationEvent? event`. When `event` is non-null, the dialog is in edit mode with pre-populated fields.

**REQ-7.3** The dialog contains:
- A `DropdownButtonFormField<String>` for `eventType`, populated from `AppConstants.eventTypes`, with each item showing the event type's icon and label.
- A read-only `TextFormField` for `eventDate` that displays the selected date in `"YYYY-MM-DD"` format, with a calendar icon button that opens `showDatePicker`. The date picker's `lastDate` is set to `DateTime(2100)` (allowing future dates for scheduled events).
- A multiline `TextFormField` for `notes` (optional, `maxLines: 3`).

**REQ-7.4** The date picker's `firstDate` is `DateTime(2000)` and `lastDate` is `DateTime(2100)`.

**REQ-7.5** Both `eventType` and `eventDate` are required. The Save button is disabled until both are selected. `notes` is always optional.

**REQ-7.6** The dialog title is `"Add Event"` in create mode and `"Edit Event"` in edit mode.

**REQ-7.7** The dialog has Cancel and Save action buttons. The Save button shows a `CircularProgressIndicator` while the API call is in progress. Both buttons are disabled during save.

**REQ-7.8** `AddEventDialog.onSave` is a callback `Future<void> Function(ApplicationEvent)` invoked with the resulting `ApplicationEvent` after a successful API call. The calling screen handles state update; the dialog does not close itself — the caller closes it after the callback completes.

---

### REQ-8 — Constraints and Invariants

**REQ-8.1** The `JobApplication.status` field and all existing status-based features (Kanban board, filter dropdown, dashboard stat cards, `statusToKanbanColumn`, `getNextAction`, status action menu, `pendingOA`/`pendingInterview` metrics) are unchanged.

**REQ-8.2** The existing embedded `timeline` array in `JobApplication` documents in MongoDB must not be modified, cleared, or removed by any code introduced in this feature. It remains for backward compatibility.

**REQ-8.3** No new Flutter packages may be added. The implementation uses only packages already in `pubspec.yaml`: `flutter`, `http`, `url_launcher`, `file_picker`, `open_filex`, `cupertino_icons`.

**REQ-8.4** The dark theme and existing visual design language must be preserved. No theme colours, typography, or spacing constants are changed.

**REQ-8.5** All new API calls must use the same `_timeout = Duration(seconds: 15)` and the `_baseUrl = 'https://job-tracker-api-vavk.onrender.com'` already defined in `ApiService`.

**REQ-8.6** Error handling in all new API calls follows the existing pattern: user-facing SnackBar messages, `debugPrint` for technical details, no app crashes.

**REQ-8.7** `eventDate` allows future dates so users can log upcoming scheduled events (e.g., an interview booked for next week). There is no validation that `eventDate` must be in the past.

---

## What Is Not In Scope

- No changes to the Home Screen, Kanban view, list cards, or dashboard metrics.
- No changes to `AddApplicationScreen` or `ResumeLibraryScreen`.
- No authentication, notifications, or analytics.
- No changes to the Resume feature.
- No bulk-import of events or CSV export.
- No changes to the `JobApplication.status` field semantics or allowed values.

---

## Glossary

| Term | Definition |
|---|---|
| `ApplicationEvent` | A first-class MongoDB document recording a single recruitment event for one job application |
| `eventType` | The category of recruitment milestone (e.g., "OA Scheduled", "Interview Completed") |
| `eventDate` | The real-world calendar date on which the event occurred or is scheduled to occur |
| `createdAt` | Server-generated timestamp recording when the event document was first saved |
| Embedded timeline | The existing `List<TimelineEvent>` array inside `JobApplication` documents — preserved but no longer the primary timeline data source |
| `ApplicationTimeline` widget | The existing Flutter widget that renders embedded `TimelineEvent` objects — retained but no longer used in `ApplicationDetailsScreen` |
| Cascade delete | Automatic removal of all `ApplicationEvent` documents belonging to an application when that application is deleted |
