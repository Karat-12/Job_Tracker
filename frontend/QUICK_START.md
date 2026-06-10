# Job Tracker - Quick Start Guide

## 🚀 Get Started in 3 Steps

### 1️⃣ Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2️⃣ Run the App
```bash
flutter run
```

### 3️⃣ Explore Features!
- Add applications via FAB (+)
- Search by company/role
- Filter by status
- Sort applications
- Toggle List/Kanban view
- Drag cards in Kanban to change status
- Edit/Delete applications

---

## 📱 What's Inside

### ✨ Main Features
- ✅ Dashboard with 6 stat cards (Total, Applied, OA, Interview, Selected, Rejected)
- ✅ Real-time search (company name & role)
- ✅ Filter by status
- ✅ 4 sort options (Latest/Oldest applied, A-Z/Z-A)
- ✅ List view with full details
- ✅ Kanban board with drag-and-drop
- ✅ Add/Edit applications with validation
- ✅ Delete with confirmation dialog
- ✅ Material 3 dark theme (supports light too)
- ✅ Responsive design (mobile/tablet/desktop)

### 📁 File Structure
```
lib/
├── main.dart (App entry & theme)
├── models/application.dart (Data model)
├── screens/
│   ├── home_screen.dart (Main dashboard)
│   └── add_application_screen.dart (Add/Edit form)
├── widgets/ (5 reusable components)
├── services/sample_data.dart (6 sample apps)
└── utils/ (Constants & formatters)
```

### 📚 Documentation
- **FEATURES.md** - Complete feature list
- **ARCHITECTURE.md** - System design & diagrams
- **IMPLEMENTATION_GUIDE.md** - Technical details
- **COMPLETED.md** - What was built

---

## 🎯 Key Interactions

### Search & Filter
```
Type in search box → Results update in real-time
Select status filter → See only that status
Combine both → Get precise results
```

### Kanban Board
```
Click "Kanban" button → View by status columns
Drag card to new column → Status updates automatically
Dashboard stats refresh → All counts update
```

### Add Application
```
Click FAB (+) → Fill form → Validate fields
Company Name & Role required → Date must be YYYY-MM-DD
Click Save → Returns to Home → Stats update
```

### Edit Application
```
Click Edit on card → Form pre-fills → Modify fields
Click Update → Returns to Home → Stats update
```

### Delete Application
```
Click Delete on card → Confirm dialog appears
Click Delete again → App removed → Stats update
```

---

## 📊 Sample Data

Pre-loaded with 6 applications:
1. **Google** - SDE Intern (Applied)
2. **Amazon** - Backend Intern (OA)
3. **Nokia** - Software Intern (Interview)
4. **Microsoft** - Full Stack Intern (Selected)
5. **Apple** - iOS Developer Intern (Rejected)
6. **Meta** - Backend Engineer Intern (Applied)

Delete all and create your own, or edit existing ones!

---

## 🎨 Customization

### Change Colors
Edit `lib/utils/constants.dart`:
```dart
AppConstants.getStatusColor(status) {
  // Modify color mapping here
}
```

### Change Theme
Edit `lib/main.dart`:
```dart
seedColor: Colors.indigo, // Change primary color
```

### Add More Status Options
Edit `lib/utils/constants.dart`:
```dart
static const List<String> statuses = [...];
```

---

## 💡 Tips & Tricks

### Search Tips
- Search is case-insensitive
- Searches company name & role
- Type partial names (e.g., "goo" finds "Google")

### Kanban Tips
- Drag any card to any column
- Status updates instantly
- Can filter/search within Kanban

### Form Tips
- Date format: YYYY-MM-DD (e.g., 2026-06-07)
- Company Name & Role are required
- Optional fields can be left blank
- Notes support multiline text

### Performance Tips
- App runs smoothly with 100+ applications
- For 1000+ apps, consider adding pagination
- All operations are instant (in-memory)

---

## 🐛 Troubleshooting

### App won't run?
```bash
flutter clean
flutter pub get
flutter run
```

### Form validation error on date?
- Make sure format is: YYYY-MM-DD
- Use zeros for single digits: 2026-06-07 (not 2026-6-7)

### Changes not showing?
- Ensure `setState()` is called
- Check that model.copyWith() is creating new instance

### Drag-drop not working?
- Make sure you're in Kanban view
- Drag from center of card
- Drop exactly on column area

---

## 🚀 Next Steps

### Short Term
1. Add new applications manually
2. Try all views (List & Kanban)
3. Test search/filter/sort combinations
4. Edit and delete applications

### Medium Term
1. Customize colors in constants.dart
2. Add more sample applications
3. Test on different screen sizes

### Long Term
1. Add SQLite database for persistence
2. Add export to CSV/PDF
3. Add interview scheduling
4. Add salary tracking

---

## 📞 App Structure at a Glance

```
User Interface (Screens)
    ↓
State Management (StatefulWidget)
    ↓
Business Logic (Filter/Sort/Search)
    ↓
Data Model (Application class)
    ↓
Utilities (Constants & Formatters)
```

---

## ✅ What's Included

✅ Full CRUD (Create, Read, Update, Delete)
✅ Advanced search & filtering
✅ Drag-and-drop Kanban
✅ Form validation
✅ Material 3 design
✅ Dark theme support
✅ Responsive layout
✅ In-memory data (session persistence)
✅ 6 sample applications
✅ Comprehensive documentation

---

## 📄 Requirements Met

✅ Modern professional UI
✅ Material 3 + Dark theme
✅ Responsive design
✅ Dashboard with stats
✅ Search functionality
✅ Filter by status
✅ Sort options
✅ Kanban board view
✅ Drag-and-drop support
✅ Add/Edit/Delete operations
✅ Form validation
✅ No external state management
✅ Clean architecture
✅ Hardcoded sample data

---

## 🎓 Learning This App

This app demonstrates:
- StatefulWidget patterns
- Material 3 design system
- Form validation
- Drag and drop
- State management
- Filter/sort algorithms
- Navigation patterns
- Dialog usage
- Responsive design
- Code organization

---

## 🎯 Have Fun! 

The app is production-ready and fully functional. 
Enjoy tracking your job applications! 🚀

For detailed info, check:
- **FEATURES.md** - What the app does
- **ARCHITECTURE.md** - How it's built
- **IMPLEMENTATION_GUIDE.md** - Technical details
