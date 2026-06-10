# Job Tracker - Flutter Application

A professional, feature-rich Flutter application for tracking internship and job applications.

## ✨ Features

### 📊 Dashboard
- **Real-time Statistics**: View counts for Total, Applied, OA, Interview, Selected, and Rejected applications
- **Dynamic Calculation**: Statistics automatically update as you add, edit, or delete applications
- **Color-coded Status Cards**: Each status has a unique, visually distinct color for easy identification

### 🔍 Search & Filter
- **Real-time Search**: Search applications by company name or role as you type
- **Status Filtering**: Filter applications by status (All, Applied, OA, Interview, Selected, Rejected)
- **Combined Search + Filter**: Use both together for precise results

### 📋 Sorting Options
- **Latest Applied**: Most recent applications first
- **Oldest Applied**: Oldest applications first
- **Company A-Z**: Alphabetical sorting by company name
- **Company Z-A**: Reverse alphabetical sorting

### 👀 Multiple Views
- **List View**: Traditional card-based list with full application details
- **Kanban View**: Organize applications by status in columns
  - Drag and drop applications between columns to change status
  - Status updates automatically when moved
  - Dashboard stats refresh in real-time

### ➕ Application Management
- **Add Applications**: Comprehensive form with validation
  - Company Name (required)
  - Role (required)
  - Source (optional)
  - Job Link (optional)
  - Date Applied (required, YYYY-MM-DD format)
  - Status (5 options: Applied, OA, Interview, Selected, Rejected)
  - Notes (optional, multiline)

- **Edit Applications**: Modify existing application details
  - Pre-filled form with current values
  - Same validation as add form
  - Status changes reflected immediately

- **Delete Applications**: Confirm before deletion
  - Confirmation dialog prevents accidental deletions
  - Statistics update automatically

### 🎨 Modern UI/UX
- **Material 3 Design**: Modern, clean interface following Material Design 3 guidelines
- **Dark Theme Support**: Optimized for both light and dark modes
- **Responsive Layout**: Adapts seamlessly to mobile, tablet, and desktop screens
- **Rounded Cards**: Consistent use of rounded corners throughout
- **Color-coded Status Indicators**: Visual status representation with custom colors
- **Gradient Effects**: Subtle gradients on dashboard cards for visual appeal

### 🗄️ Data Management
- **In-Memory State**: No external dependencies or backend required
- **Persistent During Session**: Data persists while app is running
- **Sample Data**: Pre-populated with realistic job applications
- **Full CRUD Operations**: Create, Read, Update, Delete functionalities

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point, theme configuration
├── models/
│   └── application.dart               # Application data model with copyWith
├── screens/
│   ├── home_screen.dart              # Main dashboard with search, filter, sort, and view toggle
│   └── add_application_screen.dart   # Form for adding/editing applications
├── widgets/
│   ├── dashboard_card.dart           # Enhanced status card with gradients
│   ├── application_list_card.dart    # List view card with full details
│   ├── kanban_card.dart              # Kanban board card
│   ├── kanban_view.dart              # Kanban board with drag-and-drop
│   └── delete_confirmation_dialog.dart # Confirmation dialog
├── services/
│   └── sample_data.dart              # Hardcoded sample applications
└── utils/
    ├── constants.dart                # Constants, colors, and spacing values
    └── date_utils.dart               # Date formatting utilities
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.11.5 or later)
- Dart SDK
- Android Studio / Xcode / VS Code

### Installation

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## 📱 Application Model

Each application contains:
- **id**: Unique identifier (auto-generated on creation)
- **companyName**: Name of the company (required)
- **role**: Job position/role (required)
- **source**: Where you found the job (e.g., Careers, LinkedIn, Company Site)
- **jobLink**: URL to the job posting
- **dateApplied**: Date of application (YYYY-MM-DD format)
- **status**: Current application status (Applied, OA, Interview, Selected, Rejected)
- **notes**: Additional notes (optional, nullable)

## 🎯 Status Workflow

Applications can be in one of five statuses:
1. **Applied** (Blue): Initial submission
2. **OA** (Orange): Online Assessment stage
3. **Interview** (Purple): Interview scheduled/in progress
4. **Selected** (Green): Offer received / Position accepted
5. **Rejected** (Red): Application rejected

## 🛠️ Technology Stack

- **Framework**: Flutter
- **Design**: Material 3
- **State Management**: StatefulWidget (local state only)
- **Theming**: Material ColorScheme with dark mode support
- **Responsive Design**: MediaQuery for adaptive layouts
- **Persistence**: In-memory (session-based)

## 🎮 Key Interactions

### Search & Filter Workflow
1. Type in the search box to filter by company name or role
2. Use the status dropdown to filter by application status
3. Use the sort dropdown to arrange applications
4. All filters can be combined for precise results

### Kanban View Workflow
1. Click the "Kanban" button to switch to column view
2. Each column represents a status category
3. Drag a card to another column to update its status
4. Dashboard automatically recalculates stats
5. Filter and search still work in Kanban view

### Edit & Delete Workflow
1. Click "Edit" on any application card to modify it
2. Pre-filled form shows current values
3. Click "Delete" to remove an application
4. Confirm deletion in the dialog
5. All changes reflect immediately in stats and views

## 💾 Sample Data

The app comes with 6 pre-populated applications:
- Google (SDE Intern - Applied)
- Amazon (Backend Intern - OA)
- Nokia (Software Intern - Interview)
- Microsoft (Full Stack Intern - Selected)
- Apple (iOS Developer Intern - Rejected)
- Meta (Backend Engineer Intern - Applied)

## 🎨 UI Customization

### Constants
Edit `lib/utils/constants.dart` to modify:
- Status colors
- Spacing values
- Border radius
- Status list

### Theme
Edit `lib/main.dart` to customize:
- Primary color (currently Indigo)
- Light/Dark theme colors
- Material 3 seed color

## 📊 Statistics

The dashboard dynamically calculates:
- **Total Applications**: Count of all applications
- **By Status**: Individual counts for each status category
- **Automatic Updates**: Stats refresh when applications are added, edited, or deleted

## ✅ Form Validation

The Add/Edit form validates:
- Company Name: Cannot be empty
- Role: Cannot be empty
- Date Applied: Must be in YYYY-MM-DD format and valid date
- Status: Always has a default value

## 🎯 Future Enhancement Ideas

- Save data to local database (SQLite)
- Export applications to CSV/PDF
- Interview preparation reminders
- Salary expectations tracking
- Application timeline visualization
- Analytics and success rate metrics
- Cloud sync across devices
- Push notifications for interview dates

## 📄 License

This project is for educational and personal use.

## 👨‍💻 Author

Created as a professional job tracking solution with Flutter best practices.
