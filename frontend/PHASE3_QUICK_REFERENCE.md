# Phase 3 Quick Reference Guide

## New Screens

### ApplicationDetailsScreen
**Path**: `lib/screens/application_details_screen.dart`
**Accessed**: Tap any application card
**Features**:
- Full application information display
- Company name, role, source, date applied
- Status badge with color coding
- Clickable job link (opens in browser)
- Notes section
- Edit and Delete buttons
- Professional card-based layout

## New Widgets

### EmptyStateWidget
**Path**: `lib/widgets/empty_state_widget.dart`
**When Used**: When `_applications` list is empty
**Features**:
- Large icon (assignment_icon)
- Message: "No Applications Yet"
- Call-to-action button to add applications
- Professional styling with gradients

### StatusActionMenu
**Path**: `lib/widgets/status_action_menu.dart`
**Integrated Into**: ApplicationListCard and KanbanCard
**Features**:
- 3-dot menu icon
- PopupMenuButton with all statuses except current
- Color-coded status options
- Direct status updates

## Modified Widgets

### ApplicationListCard
**Changes**:
- Now tappable (InkWell wrapper)
- Added `onDetails` callback
- Added `onStatusChanged` callback
- StatusActionMenu integrated

### KanbanCard
**Changes**:
- Now tappable (InkWell wrapper)
- Added `onDetails` callback
- Added `onStatusChanged` callback
- StatusActionMenu integrated
- Updated button layout to fit menu

### KanbanView
**Changes**:
- Updated `onStatusChanged` signature: `(Application, String)`
- Added `onDetails` callback
- Passes new callbacks to KanbanCard

### DashboardCard
**Changes**:
- Added optional `icon` parameter
- Displays icon alongside title and count
- Responsive layout with icon alignment

### HomeScreen
**Major Changes**:
1. Dashboard section now includes:
   - Status cards with icons
   - Response Rate card
   - Success Rate card
2. Search expanded to include source field
3. Empty state handling with EmptyStateWidget
4. Details screen navigation
5. Updated callback signatures
6. Improved stat calculations

## Updated Utilities

### AppConstants
**New Methods**:
```dart
static IconData getStatusIcon(String status)
  // Returns: Icons.send, Icons.assignment, Icons.forum, etc.

static String getStatusLabel(String status)
  // Returns: "Applications Sent", "Online Assessments", etc.
```

## Key Navigation Flows

### Viewing Application Details
```
Home Screen
  ↓ (Tap card in list or Kanban)
Details Screen
  ↓ (Edit button)
Edit Application Screen
  ↓ (Save)
Back to Home (updated)
```

### Quick Status Update
```
Home Screen (List or Kanban)
  ↓ (Tap 3-dot menu)
Status Menu
  ↓ (Select new status)
Immediate Update (State refresh)
```

### Empty Application List
```
Home Screen
  ↓ (No applications)
Empty State Widget
  ↓ (Tap "Add Application" button)
Add Application Screen
  ↓ (Save)
Back to Home (with new application)
```

## State Management Callbacks

### HomeScreen Callbacks
```dart
void _handleAddApplication()
  // Create new application

void _handleEditApplication(Application app)
  // Navigate to edit screen

void _handleDeleteApplication(Application app)
  // Remove from list

void _handleStatusChanged(Application app, String newStatus)
  // Update status field

void _handleShowDetails(Application app)
  // Navigate to details screen
```

## Calculation Methods

### Response Rate
Formula: `(OA + Interview + Selected) / Total × 100%`
Interpretation: Percentage of applications that received a response

### Success Rate
Formula: `Selected / Total × 100%`
Interpretation: Percentage of applications that resulted in offers

## Layout Improvements

### Dashboard Row (Updated)
- **Before**: 6 cards
- **After**: 6 cards + 2 stat cards + icons on all

### Search Hint (Updated)
- **Before**: "Search by company or role"
- **After**: "Search by company, role, or source"

### Empty State (New)
- Shows when `_applications.isEmpty`
- Professional UI with icon and action button
- Replaces entire body when no data

## Testing Key Points

1. **Details Screen**
   - Open from list view ✓
   - Open from Kanban view ✓
   - Edit button works ✓
   - Delete button works ✓
   - Link opens in browser ✓

2. **Status Menu**
   - Appears on both card types ✓
   - Shows all statuses except current ✓
   - Updates immediately ✓

3. **Dashboard Stats**
   - Response Rate calculates correctly ✓
   - Success Rate calculates correctly ✓
   - Updates when applications change ✓

4. **Search**
   - Works for company names ✓
   - Works for roles ✓
   - Works for sources ✓
   - Case-insensitive ✓

5. **Empty State**
   - Shows when list empty ✓
   - Hides when applications added ✓
   - Add button works ✓

## File Dependencies

```
main.dart
├── home_screen.dart ─┬─ dashboard_card.dart
│                     ├─ application_list_card.dart ─┬─ status_action_menu.dart
│                     │                               └─ empty_state_widget.dart
│                     ├─ kanban_view.dart ─ kanban_card.dart ─ status_action_menu.dart
│                     ├─ application_details_screen.dart
│                     ├─ add_application_screen.dart
│                     └─ constants.dart
```

## Performance Notes

- All calculations are O(n) where n = number of applications
- Dashboard updates only on state change (no continuous recalculation)
- Search is instant with no debouncing needed (small datasets)
- No async operations in widget build
- Responsive layout uses SingleChildScrollView for horizontal scroll

## Accessibility Improvements

- All buttons have proper labels and tooltips
- Color coding supplemented with icons
- Text sizes follow Material 3 specs
- Touch targets minimum 48x48 dp
- Semantic labels for menu buttons
- Alt text through icon tooltips

## Known Limitations

1. No backend/database - data persists only in session
2. No URL launcher error handling (links that fail silently)
3. No pagination for large application lists
4. No offline support
5. No real-time sync across devices

These can be addressed in future phases.
