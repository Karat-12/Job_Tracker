import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/add_application_screen.dart';
import 'models/application.dart';

void main() {
  runApp(const JobTrackerApp());
}

class JobTrackerApp extends StatelessWidget {
  const JobTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tracker',
      themeMode: ThemeMode.dark,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      routes: {
        '/': (context) => const HomeScreen(),
        '/add': (context) => const AddApplicationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final app = settings.arguments as Application;
          return MaterialPageRoute(
            builder: (context) => AddApplicationScreen(application: app),
          );
        }
        return null;
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
    );
  }
}
