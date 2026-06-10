# Job Tracker - Implementation Guide

## Project Overview

A professional Flutter application for managing job application tracking with advanced features like search, filtering, sorting, and a Kanban board view. Built with Material 3 design system and supporting both light and dark themes.

## Architecture Overview

### Layered Architecture

```
┌─────────────────────────────────────────┐
│          Presentation Layer             │
│  (Screens & Widgets)                   │
├─────────────────────────────────────────┤
│          Business Logic Layer            │
│  (HomeScreen State Management)          │
├─────────────────────────────────────────┤
│          Data Layer                      │
│  (Models, Services)                    │
├─────────────────────────────────────────┤
│          Utility Layer                   │
│  (Constants, Formatters)               │
└─────────────────────────────────────────┘
```

## File-by-File Explanation

### `lib/main.dart`
- **Purpose**: App entry point and theme configuration
- **Key Features**:
  - Material 3 theme with ColorScheme
  - Dark theme support (default)
  - Route configuration (named routes + onGenerateRoute for edit)
  - Light and dark theme builders

### `lib/models/application.dart`
- **Purpose**: Data model for job applications
- **Key Methods**:
  - Constructor with required/optional parameters
  - `copyWith()`: Immutable copy with optional field overrides
- **Fields**: id, companyName, role, source, jobLink, dateApplied, status, notes

### `lib/services/sample_data.dart`
- **Purpose**: Hardcoded sample data for demonstration
- **Contains**: 6 pre-populated Application objects with different statuses
- **Use Case**: Development and testing without backend

### `lib/utils/constants.dart`
- **Purpose**: Centralized constants for the application
- **Contains**:
  - `AppConstants.statuses`: List of all possible status values
  - `AppConstants.getStatusColor()`: Maps status to Color
  - `AppSpacing`: Consistent spacing values (xs, sm, md, lg, xl)
  - `AppBorderRadius`: Consistent border radius values

### `lib/utils/date_utils.dart`
- **Purpose**: Date formatting utilities
- **Methods**:
  - `formatDate()`: Returns "DD Mon YYYY" format
  - `formatDateShort()`: Returns "YYYY-MM-DD" format
  - `_monthName()`: Helper for month abbreviation

### `lib/screens/home_screen.dart`
- **Purpose**: Main dashboard and application list view
- **State Variables**:
  - `_applications`: List of current applications
  - `_searchQuery`: Current search text
  - `_selectedFilter`: Current status filter
  - `_sortBy`: Current sort option
  - `_isKanbanView`: Toggle between list/kanban
- **Key Methods**:
  - `_getFilteredAndSortedApplications()`: Combines search, filter, sort
  - `_calculateStats()`: Computes dashboard statistics
  - `_handleAddApplication()`: Navigate to add screen and add result
  - `_handleEditApplication()`: Navigate to edit screen and update result
  - `_handleDeleteApplication()`: Show delete confirmation and remove
  - `_handleStatusChanged()`: Handle Kanban drag-drop status update

### `lib/screens/add_application_screen.dart`
- **Purpose**: Form for adding and editing applications
- **Dual Mode**:
  - Add mode: Empty form (default)
  - Edit mode: Pre-filled form (when `application` parameter provided)
- **Validation**:
  - Company Name: Required, non-empty
  - Role: Required, non-empty
  - Date Applied: Required, must be valid YYYY-MM-DD format
- **Form Fields**: 
  - Text inputs: companyName, role, source, jobLink, notes
  - Date input: dateApplied
  - Dropdown: status
- **Return Value**: Updated/new Application object

### `lib/widgets/dashboard_card.dart`
- **Purpose**: Status statistics card with gradient
- **Features**:
  - Material 3 rounded corners
  - Gradient background based on color
  - Flexible sizing
  - Optional custom color

### `lib/widgets/application_list_card.dart`
- **Purpose**: Enhanced list view card with full application details
- **Displays**:
  - Company name (bold)
  - Role
  - Status badge (color-coded)
  - Source and applied date
  - Notes (if present)
  - Edit/Delete action buttons
- **Callbacks**: onEdit, onDelete

### `lib/widgets/kanban_card.dart`
- **Purpose**: Compact card for Kanban board view
- **Features**:
  - Smaller size optimized for columns
  - Status border highlight
  - Compact action buttons
  - Date in short format

### `lib/widgets/kanban_view.dart`
- **Purpose**: Kanban board with drag-and-drop
- **Architecture**:
  - Creates columns for each status
  - Uses `DragTarget` to detect drops
  - Uses `Draggable` to enable dragging
  - Callbacks for status change, edit, delete
- **Features**:
  - Visual feedback on drag
  - Application count per column
  - Responsive column layout

### `lib/widgets/delete_confirmation_dialog.dart`
- **Purpose**: Confirmation dialog before deletion
- **Components**:
  - Title: "Delete Application"
  - Message: Displays company name
  - Cancel button: Dismisses dialog
  - Delete button: Executes onConfirm callback

## Data Flow

### Add Application Flow
```
User → FAB click → AddApplicationScreen (empty form)
→ Fill form → Validate → Create Application
→ Return to HomeScreen → Add to _applications list
→ setState() → Recalculate stats → UI refresh
```

### Edit Application Flow
```
User → Click Edit → AddApplicationScreen (pre-filled form)
→ Modify fields → Validate → Create updated Application
→ Return to HomeScreen → Update _applications[index]
→ setState() → Recalculate stats → UI refresh
```

### Delete Application Flow
```
User → Click Delete → Show DeleteConfirmationDialog
→ Click Delete → Remove from _applications
→ setState() → Recalculate stats → UI refresh
```

### Search & Filter Flow
```
User → Type search query → setState()
→ _getFilteredAndSortedApplications() processes
→ Apply search filter → Apply status filter
→ Apply sort logic → Return filtered list
→ ListView displays result
```

### Kanban Drag-Drop Flow
```
User → Drag card to new column → DragTarget detects
→ onAcceptWithDetails fired → Extract Application
→ Create new Application with updated status
→ Call _handleStatusChanged()
→ setState() → Update _applications
→ Recalculate stats → UI refresh
```

## State Management Pattern

### StatefulWidget Pattern
- **Why**: Simple local state, no external dependencies needed
- **How**: _HomeScreenState manages application list and filters
- **setState()**: Triggers rebuild for UI updates

### Immutable Data Model
- **copyWith()**: Creates new instances instead of mutating
- **Benefits**: Easier debugging, predictable state changes

### Local Search/Filter/Sort
- **Real-time Processing**: No database queries
- **Performance**: Suitable for ~100-1000 applications
- **Scalability**: For larger datasets, consider pagination/virtualization

## UI Design System

### Colors (from AppConstants)
- **Applied**: Blue
- **OA**: Orange
- **Interview**: Purple
- **Selected**: Green
- **Rejected**: Red

### Spacing System
```
xs = 4 px
sm = 8 px
md = 12 px
lg = 16 px
xl = 24 px
```

### Border Radius
```
sm = 8 px (small elements)
md = 12 px (cards, inputs)
lg = 16 px (large containers)
```

## Form Validation

### Validation Rules
```
Company Name: !isEmpty()
Role: !isEmpty()
Date Applied: isValidDate(YYYY-MM-DD)
Status: Always has default value
```

### Date Format
- **Input**: YYYY-MM-DD (e.g., "2026-06-07")
- **Parse**: Split by '-', convert to int, create DateTime
- **Display**: Use DateFormatUtil.formatDate() for UI

## Search Implementation

### Real-time Search Algorithm
```dart
// Pseudo-code
if (searchQuery.isEmpty) return allApps;

final query = searchQuery.toLowerCase();
return apps.where((app) =>
  app.companyName.toLowerCase().contains(query) ||
  app.role.toLowerCase().contains(query)
).toList();
```

### Optimizations
- Case-insensitive matching
- Searches both companyName and role
- Debouncing optional (can add with timer)

## Sorting Implementation

### Sort Strategies
```dart
// Latest Applied: Most recent first
sort((a, b) => b.dateApplied.compareTo(a.dateApplied))

// Oldest Applied: Oldest first
sort((a, b) => a.dateApplied.compareTo(b.dateApplied))

// Company A-Z: Alphabetical ascending
sort((a, b) => a.companyName.compareTo(b.companyName))

// Company Z-A: Alphabetical descending
sort((a, b) => b.companyName.compareTo(a.companyName))
```

## Future Enhancement Paths

### Short Term
- Add date picker instead of text input
- Add company logo/image
- Add interview date tracking
- Add salary expectations

### Medium Term
- SQLite local database
- Export to CSV/PDF
- Notification system
- Analytics dashboard

### Long Term
- Backend API integration
- Cloud sync
- Multi-device support
- Job market analysis
- Recommendation engine

## Testing Considerations

### Unit Tests
- Application model copyWith
- DateFormatUtil functions
- AppConstants color mapping

### Widget Tests
- Form validation
- Search filtering
- Sort ordering
- Kanban drag-drop interaction

### Integration Tests
- Complete add/edit/delete flows
- Navigation between screens
- State persistence during session

## Performance Optimization Tips

1. **Large Lists**: Add virtualization with `ListView.builder`
2. **Search**: Debounce text input
3. **Animations**: Use `AnimationController` for smooth transitions
4. **Images**: Lazy load company logos
5. **Memory**: Consider pagination for 1000+ applications

## Deployment Checklist

- [ ] Test on Android device/emulator
- [ ] Test on iOS device/emulator (if available)
- [ ] Test on web (if needed)
- [ ] Replace sample data with empty list
- [ ] Add local storage persistence
- [ ] Configure app signing
- [ ] Update version numbers
- [ ] Write privacy policy
- [ ] Create app store listings

## Common Issues & Solutions

### Issue: Kanban view not updating after drag
**Solution**: Ensure `_handleStatusChanged()` calls `setState()`

### Issue: Search not case-insensitive
**Solution**: Use `.toLowerCase()` for both query and data

### Issue: Form validation errors not showing
**Solution**: Ensure `validator` returns error message string

### Issue: Date parsing fails
**Solution**: Validate date format is YYYY-MM-DD, use try-catch

### Issue: UI doesn't update after add/edit
**Solution**: Wrap changes in `setState()` callback

