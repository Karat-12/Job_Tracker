# Job Tracker - Architecture & Flow Diagrams

## Overall Application Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    Job Tracker App                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           main.dart (App Entry Point)                │  │
│  │  - Material 3 Theme Configuration                    │  │
│  │  - Dark/Light Theme Setup                            │  │
│  │  - Route Configuration                               │  │
│  └────────────────────┬─────────────────────────────────┘  │
│                       │                                      │
│          ┌────────────┴────────────────┐                   │
│          │                             │                   │
│    ┌─────▼─────────┐         ┌────────▼──────────┐         │
│    │ HomeScreen    │         │ AddApplication    │         │
│    │ (Stateful)    │         │ Screen (Stateful) │         │
│    │               │         │                   │         │
│    │ - Search      │         │ - Form Validation │         │
│    │ - Filter      │         │ - Add/Edit Mode   │         │
│    │ - Sort        │         │ - Date Picker     │         │
│    │ - List View   │         │ - Status Dropdown │         │
│    │ - Kanban View │         │ - Notes Field     │         │
│    └──────┬────────┘         └─────────┬────────┘         │
│           │                            │                  │
│  ┌────────┴────────────────────────────┴──────────┐      │
│  │          Widgets (Reusable Components)         │      │
│  │                                                 │      │
│  │  ├─ dashboard_card.dart                        │      │
│  │  ├─ application_list_card.dart                 │      │
│  │  ├─ kanban_card.dart                           │      │
│  │  ├─ kanban_view.dart                           │      │
│  │  └─ delete_confirmation_dialog.dart            │      │
│  └────────┬─────────────────────────────────────┘      │
│           │                                             │
│  ┌────────┴──────────────────────────────────────┐     │
│  │       Data & Services Layer                   │     │
│  │                                                │     │
│  │  ├─ Application (Model)                       │     │
│  │  └─ sample_data.dart (Service)                │     │
│  └────────┬──────────────────────────────────────┘     │
│           │                                             │
│  ┌────────┴──────────────────────────────────────┐     │
│  │       Utilities Layer                         │     │
│  │                                                │     │
│  │  ├─ constants.dart                            │     │
│  │  │  └─ Colors, Spacing, Status List          │     │
│  │  │                                             │     │
│  │  └─ date_utils.dart                           │     │
│  │     └─ Date Formatting Functions             │     │
│  └────────────────────────────────────────────────┘     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## State Flow in HomeScreen

```
┌──────────────────────────┐
│  Initial State Setup     │
│  - Copy sample data      │
│  - Empty search query    │
│  - Filter: All           │
│  - Sort: Latest Applied  │
│  - View: List            │
└────────────┬─────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────┐
│                   User Interactions                      │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │  Search  │  │  Filter  │  │   Sort   │  │ Toggle │ │
│  │          │  │          │  │          │  │  View  │ │
│  └────┬─────┘  └─────┬────┘  └────┬─────┘  └───┬────┘ │
│       │              │             │            │      │
│       └──────────────┼─────────────┼────────────┘      │
│                      │             │                   │
│         ┌────────────▼─────────────▼──────────────┐    │
│         │      setState() triggered              │    │
│         └────────────┬──────────────────────────┘    │
│                      │                               │
│         ┌────────────▼──────────────────────────┐    │
│         │ _getFilteredAndSortedApplications()  │    │
│         │ - Apply search filter                │    │
│         │ - Apply status filter                │    │
│         │ - Apply sort logic                   │    │
│         └────────────┬──────────────────────────┘    │
│                      │                               │
│         ┌────────────▼──────────────────────────┐    │
│         │ Rebuild UI with filtered results     │    │
│         └────────────────────────────────────────┘    │
│                                                       │
└─────────────────────────────────────────────────────┘
```

## Add/Edit/Delete Flow

```
┌─────────────────────────────────────────────────────────┐
│                      User Actions                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│  │   FAB    │    │   Edit   │    │  Delete  │         │
│  │  (Add)   │    │  Button  │    │  Button  │         │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘         │
│       │               │               │               │
│       ▼               ▼               ▼               │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐    │
│  │ Navigate │    │ Navigate │    │   Show       │    │
│  │ to Add   │    │ to Edit  │    │ Confirmation│    │
│  │ Screen   │    │ Screen   │    │ Dialog       │    │
│  │          │    │ w/ App   │    │              │    │
│  └────┬─────┘    └────┬─────┘    └────┬─────────┘    │
│       │               │               │               │
│       ▼               ▼               │               │
│  ┌─────────────────────────────┐    │               │
│  │   Add Application Screen    │    │               │
│  │                             │    │               │
│  │  - Empty form (Add)         │    │               │
│  │  - Pre-filled (Edit)        │    │               │
│  │  - Validate inputs          │    │               │
│  │  - Return Application       │    │               │
│  └────────────┬────────────────┘    │               │
│               │                      │               │
│               ▼                      ▼               │
│  ┌──────────────────────────────────────────────┐   │
│  │    HomeScreen Callbacks                      │   │
│  │                                              │   │
│  │  Add:    _applications.add(result)           │   │
│  │  Edit:   _applications[index] = result       │   │
│  │  Delete: _applications.removeWhere(...)      │   │
│  └────────────┬─────────────────────────────────┘   │
│               │                                      │
│               ▼                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │          setState() Called                   │   │
│  └────────────┬─────────────────────────────────┘   │
│               │                                      │
│    ┌──────────┴──────────┐                          │
│    │                     │                          │
│    ▼                     ▼                          │
│ ┌────────────┐     ┌──────────────┐               │
│ │ Recalc     │     │  Update UI   │               │
│ │ Dashboard  │     │              │               │
│ │ Stats      │     │ - List View  │               │
│ │            │     │ - Kanban     │               │
│ └────────────┘     │ - Stats      │               │
│                    └──────────────┘               │
│                                                    │
└────────────────────────────────────────────────────┘
```

## Kanban Drag-Drop Flow

```
┌──────────────────────────────────────────────────────┐
│         Kanban Board - Drag & Drop Interaction       │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────────────────────────────────────┐   │
│  │  Applied  │  OA  │ Interview │ Selected │  │   │
│  │  ┌──────┐ │      │           │          │  │   │
│  │  │Google│ │      │           │          │  │   │
│  │  └──────┘ │      │           │          │  │   │
│  └──────────────────────────────────────────────┘   │
│       │                                              │
│       │ User drags Google card to OA column         │
│       ▼                                              │
│  ┌──────────────────────────────────────────────┐   │
│  │  Applied  │  OA  │ Interview │ Selected │  │   │
│  │           │┌─────┐│           │          │  │   │
│  │           ││Google││           │          │  │   │
│  │           │└─────┘│           │          │  │   │
│  └──────────────────────────────────────────────┘   │
│       │                                              │
│       │ DragTarget detects drop                     │
│       │ Extracts Application object                │
│       ▼                                              │
│  ┌──────────────────────────────────────────────┐   │
│  │  Create new Application:                     │   │
│  │  updatedApp = app.copyWith(status: "OA")     │   │
│  └──────────────────────────────────────────────┘   │
│       │                                              │
│       ▼                                              │
│  ┌──────────────────────────────────────────────┐   │
│  │  Call _handleStatusChanged(updatedApp)       │   │
│  └──────────────────────────────────────────────┘   │
│       │                                              │
│       ▼                                              │
│  ┌──────────────────────────────────────────────┐   │
│  │  setState() {                                │   │
│  │    _applications[index] = updatedApp         │   │
│  │  }                                           │   │
│  └──────────────────────────────────────────────┘   │
│       │                                              │
│       ▼                                              │
│  ┌──────────────────────────────────────────────┐   │
│  │  Rebuild Kanban + Recalculate Stats         │   │
│  │                                             │   │
│  │  Applied: 0  │  OA: 1  │  ...              │   │
│  └──────────────────────────────────────────────┘   │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## Search Filter Sort Pipeline

```
All Applications: [App1, App2, App3, App4, App5, App6]
         │
         ▼
┌────────────────────────────────────────┐
│  Filter by Status (if != "All")        │
│                                        │
│  Status = "Interview" →                │
│  Keep only Interview apps              │
│                                        │
│  Result: [App3]                        │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────┐
│  Filter by Search Query                │
│  (Company Name or Role match)          │
│                                        │
│  Query = "backend" →                   │
│  Keep only apps matching query         │
│                                        │
│  Result: [App2, App5]                  │
└────────────────┬─────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────┐
│  Sort by Selected Criterion            │
│                                        │
│  "Company A-Z" →                       │
│  Sort alphabetically                   │
│                                        │
│  Result: [App2, App5] (sorted)         │
└────────────────┬─────────────────────┘
                 │
                 ▼
    Final Filtered List Displayed
```

## Form Validation Flow

```
User fills form and clicks Save
         │
         ▼
┌──────────────────────────────────┐
│ _formKey.currentState!.validate() │
└──────────────┬───────────────────┘
               │
       ┌───────┴───────┐
       │               │
       ▼               ▼
   Valid?          Invalid?
       │               │
       │               ▼
       │        ┌─────────────────┐
       │        │ Show Error Msgs │
       │        │ Block Save      │
       │        └─────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│ Extract field values             │
│ Parse date string                │
│ Create Application object        │
└──────────────┬───────────────────┘
               │
               ▼
┌──────────────────────────────────┐
│ Navigator.pop(context, newApp)   │
└──────────────┬───────────────────┘
               │
               ▼
    Return to HomeScreen
    with Application data
```

## Widget Dependency Tree

```
JobTrackerApp
├── MaterialApp
│   ├── Home: HomeScreen
│   ├── Route '/add': AddApplicationScreen
│   └── onGenerateRoute '/edit': AddApplicationScreen
│
HomeScreen (Stateful)
├── AppBar
├── Dashboard Row
│   └── DashboardCard (x6)
├── Search TextField
├── Filter Row
│   ├── DropdownButton (Status)
│   ├── DropdownButton (Sort)
│   └── SegmentedButton (List/Kanban)
├── Expanded Content
│   ├── (if ListViewMode)
│   │   └── ListView.builder
│   │       └── ApplicationListCard (x n)
│   │           ├── Buttons (Edit/Delete)
│   │           └── DeleteConfirmationDialog
│   │
│   └── (if KanbanViewMode)
│       └── KanbanView
│           └── StatusColumn (x5)
│               └── DragTarget
│                   └── Draggable<Application>
│                       └── KanbanCard
├── FloatingActionButton
│   └── AddApplicationScreen
│
AddApplicationScreen (Stateful)
├── AppBar
├── Form
│   ├── TextFormField (Company Name)
│   ├── TextFormField (Role)
│   ├── TextFormField (Source)
│   ├── TextFormField (Job Link)
│   ├── TextFormField (Date)
│   ├── DropdownButtonFormField (Status)
│   ├── TextFormField (Notes)
│   └── FilledButton (Save)
```

## File Interaction Diagram

```
main.dart
├── imports: HomeScreen, AddApplicationScreen, Application
├── creates: MaterialApp, ThemeData
└── routes to screens

HomeScreen
├── imports: Application, sample_data, widgets, utils
├── manages: List<Application>, filters, sorts
├── renders: dashboard, search, filters, views
├── calls: AddApplicationScreen (edit)
└── uses: ApplicationListCard, DashboardCard, KanbanView

AddApplicationScreen
├── imports: Application, constants
├── validates: form inputs
├── returns: Application object
└── used by: HomeScreen (add/edit route)

widgets/
├── dashboard_card.dart
│   └── uses: constants (AppSpacing, AppBorderRadius)
├── application_list_card.dart
│   └── uses: constants, date_utils
├── kanban_card.dart
│   └── uses: constants, date_utils
├── kanban_view.dart
│   └── uses: Application, constants, kanban_card
└── delete_confirmation_dialog.dart

utils/
├── constants.dart
│   └── provides: colors, spacing, border radius, status list
└── date_utils.dart
    └── provides: date formatting functions

services/
└── sample_data.dart
    └── provides: List<Application> (6 sample apps)

models/
└── application.dart
    └── provides: Application class with copyWith()
```

## Color System Mapping

```
AppConstants.getStatusColor()

Status String  →  Color        →  Usage
────────────────────────────────────────────
"Applied"      →  Colors.blue      Blue badge
"OA"           →  Colors.orange    Orange badge
"Interview"    →  Colors.purple    Purple badge
"Selected"     →  Colors.green     Green badge
"Rejected"     →  Colors.red       Red badge

Dashboard Cards:
├─ Total       → Colors.indigo
├─ Applied     → Colors.blue
├─ OA          → Colors.orange
├─ Interview   → Colors.purple
├─ Selected    → Colors.green
└─ Rejected    → Colors.red
```

## Performance Considerations

```
List Size          → Approach
─────────────────────────────────────
< 100 apps        → Use ListView.builder ✅
100-1000 apps     → Add pagination
1000+ apps        → Add virtual scrolling
Real-time sync    → Consider Provider/Riverpod

Search/Filter
─────────────────────────────────────
String contains   → O(n) - acceptable
Exact match       → O(1) - better
Large datasets    → Add debouncing
```

---

This architecture ensures:
- ✅ Clear separation of concerns
- ✅ Reusable components
- ✅ Maintainable codebase
- ✅ Scalable structure
- ✅ Easy to extend

