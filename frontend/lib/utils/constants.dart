import 'package:flutter/material.dart';

class AppConstants {
  // ---------------------------------------------------------------------------
  // Status definitions
  // ---------------------------------------------------------------------------

  /// All valid status values — used in the Add/Edit form dropdown.
  static const List<String> statuses = [
    'Applied',
    'OA Scheduled',
    'OA Completed',
    'Interview Scheduled',
    'Interview Completed',
    'Offer',
    'Rejected',
  ];

  // ---------------------------------------------------------------------------
  // Kanban column definitions
  // ---------------------------------------------------------------------------

  /// The 5 logical columns displayed in the Kanban board.
  static const List<String> kanbanColumns = [
    'Applied',
    'OA',
    'Interview',
    'Offer',
    'Rejected',
  ];

  /// Maps a granular status value to its Kanban column label.
  static String statusToKanbanColumn(String status) {
    switch (status) {
      case 'Applied':
        return 'Applied';
      case 'OA Scheduled':
      case 'OA Completed':
        return 'OA';
      case 'Interview Scheduled':
      case 'Interview Completed':
        return 'Interview';
      case 'Offer':
        return 'Offer';
      case 'Rejected':
        return 'Rejected';
      default:
        return 'Applied';
    }
  }

  // ---------------------------------------------------------------------------
  // Colors
  // ---------------------------------------------------------------------------

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Applied':
        return Colors.blue;
      case 'OA Scheduled':
        return Colors.orange;
      case 'OA Completed':
        return Colors.deepOrange;
      case 'Interview Scheduled':
        return Colors.purple;
      case 'Interview Completed':
        return Colors.deepPurple;
      case 'Offer':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Colour for a Kanban column header, keyed by column name.
  static Color getKanbanColumnColor(String column) {
    switch (column) {
      case 'Applied':
        return Colors.blue;
      case 'OA':
        return Colors.orange;
      case 'Interview':
        return Colors.purple;
      case 'Offer':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------------

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Applied':
        return Icons.send;
      case 'OA Scheduled':
        return Icons.schedule;
      case 'OA Completed':
        return Icons.assignment_turned_in;
      case 'Interview Scheduled':
        return Icons.event;
      case 'Interview Completed':
        return Icons.forum;
      case 'Offer':
        return Icons.verified;
      case 'Rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // ---------------------------------------------------------------------------
  // Dashboard labels (for stat cards)
  // ---------------------------------------------------------------------------

  static String getStatusLabel(String status) {
    switch (status) {
      case 'Applied':
        return 'Applications';
      case 'OA':
        return 'OA Stage';
      case 'Interview':
        return 'Interviews';
      case 'Offer':
        return 'Offers';
      case 'Rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  // ---------------------------------------------------------------------------
  // Next-action guidance
  // ---------------------------------------------------------------------------

  static String getNextAction(String status) {
    switch (status) {
      case 'Applied':
        return 'Waiting for OA';
      case 'OA Scheduled':
        return 'Take OA';
      case 'OA Completed':
        return 'Waiting for OA Result';
      case 'Interview Scheduled':
        return 'Prepare for Interview';
      case 'Interview Completed':
        return 'Waiting for Interview Result';
      case 'Offer':
        return 'Decision Pending';
      case 'Rejected':
        return 'Application Closed';
      default:
        return '';
    }
  }

  // ---------------------------------------------------------------------------
  // ApplicationEvent types
  // ---------------------------------------------------------------------------

  /// Ordered list of all valid event types for ApplicationEvent.
  static const List<String> eventTypes = [
    'Applied',
    'OA Scheduled',
    'OA Completed',
    'Interview Scheduled',
    'Interview Completed',
    'HR Round Scheduled',
    'HR Round Completed',
    'Offer Received',
    'Offer Accepted',
    'Rejected',
    'Joined',
  ];

  static IconData getEventTypeIcon(String eventType) {
    switch (eventType) {
      case 'Applied':
        return Icons.send;
      case 'OA Scheduled':
        return Icons.schedule;
      case 'OA Completed':
        return Icons.assignment_turned_in;
      case 'Interview Scheduled':
        return Icons.event;
      case 'Interview Completed':
        return Icons.forum;
      case 'HR Round Scheduled':
        return Icons.groups;
      case 'HR Round Completed':
        return Icons.groups_3;
      case 'Offer Received':
        return Icons.card_giftcard;
      case 'Offer Accepted':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Joined':
        return Icons.work;
      default:
        return Icons.circle_outlined;
    }
  }

  static Color getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'Applied':
        return Colors.blue;
      case 'OA Scheduled':
        return Colors.orange;
      case 'OA Completed':
        return Colors.deepOrange;
      case 'Interview Scheduled':
        return Colors.purple;
      case 'Interview Completed':
        return Colors.deepPurple;
      case 'HR Round Scheduled':
        return Colors.cyan;
      case 'HR Round Completed':
        return Colors.teal;
      case 'Offer Received':
        return Colors.lightGreen;
      case 'Offer Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Joined':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  // ---------------------------------------------------------------------------
  // Migration helper — maps old status values to new ones
  // ---------------------------------------------------------------------------

  /// Converts a legacy status string (pre-refactor) to the new value.
  /// Returns the original string if no mapping is needed.
  static String migrateStatus(String old) {
    switch (old) {
      case 'OA':
        return 'OA Completed';
      case 'Interview':
        return 'Interview Completed';
      case 'Selected':
        return 'Offer';
      default:
        return old; // 'Applied' and 'Rejected' are unchanged
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
