import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> statuses = [
    'Applied',
    'OA',
    'Interview',
    'Selected',
    'Rejected',
  ];

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Applied':
        return Colors.blue;
      case 'OA':
        return Colors.orange;
      case 'Interview':
        return Colors.purple;
      case 'Selected':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Applied':
        return Icons.send;
      case 'OA':
        return Icons.assignment;
      case 'Interview':
        return Icons.forum;
      case 'Selected':
        return Icons.verified;
      case 'Rejected':
        return Icons.close;
      default:
        return Icons.help;
    }
  }

  static String getStatusLabel(String status) {
    switch (status) {
      case 'Applied':
        return 'Applications Sent';
      case 'OA':
        return 'Online Assessments';
      case 'Interview':
        return 'Interviews';
      case 'Selected':
        return 'Offers';
      case 'Rejected':
        return 'Rejections';
      default:
        return 'Unknown';
    }
  }
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
}
