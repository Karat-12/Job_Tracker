import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/constants.dart';
import 'kanban_card.dart';

/// Kanban board with 5 logical columns: Applied | OA | Interview | Offer | Rejected.
///
/// Multiple granular statuses map to a single column:
///   OA Scheduled + OA Completed → OA column
///   Interview Scheduled + Interview Completed → Interview column
///
/// Dropping a card onto a column sets the status to the most-advanced
/// value for that column (e.g. dropping onto OA sets "OA Completed").
class KanbanView extends StatelessWidget {
  final List<Application> applications;
  final Function(Application, String) onStatusChanged;
  final Function(Application) onDetails;
  final Function(Application) onEdit;
  final Function(Application) onDelete;

  const KanbanView({
    super.key,
    required this.applications,
    required this.onStatusChanged,
    required this.onDetails,
    required this.onEdit,
    required this.onDelete,
  });

  /// Returns all applications whose status maps to [column].
  List<Application> _getAppsByColumn(String column) {
    return applications
        .where((app) => AppConstants.statusToKanbanColumn(app.status) == column)
        .toList();
  }

  /// When a card is dropped onto [column], we set status to this default value.
  String _defaultStatusForColumn(String column) {
    switch (column) {
      case 'Applied':
        return 'Applied';
      case 'OA':
        return 'OA Scheduled';
      case 'Interview':
        return 'Interview Scheduled';
      case 'Offer':
        return 'Offer';
      case 'Rejected':
        return 'Rejected';
      default:
        return 'Applied';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AppConstants.kanbanColumns
            .map((col) => _buildColumn(context, col))
            .toList(),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String column) {
    final apps = _getAppsByColumn(column);
    final columnColor = AppConstants.getKanbanColumnColor(column);

    return Container(
      width: 300,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: columnColor.withValues(alpha: 0.08),
      ),
      child: Column(
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              color: columnColor.withValues(alpha: 0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  column,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: columnColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: columnColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    apps.length.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: columnColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Drop target + card list
          Expanded(
            child: DragTarget<Application>(
              onAcceptWithDetails: (details) {
                final app = details.data;
                final targetColumn =
                    AppConstants.statusToKanbanColumn(app.status);
                if (targetColumn != column) {
                  onStatusChanged(app, _defaultStatusForColumn(column));
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: candidateData.isNotEmpty
                      ? columnColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return Draggable<Application>(
                        data: app,
                        feedback: Material(
                          child: SizedBox(
                            width: 280,
                            child: KanbanCard(
                              application: app,
                              onDetails: () => onDetails(app),
                              onStatusChanged: (s) => onStatusChanged(app, s),
                              onEdit: () => onEdit(app),
                              onDelete: () => onDelete(app),
                            ),
                          ),
                        ),
                        child: KanbanCard(
                          application: app,
                          onDetails: () => onDetails(app),
                          onStatusChanged: (s) => onStatusChanged(app, s),
                          onEdit: () => onEdit(app),
                          onDelete: () => onDelete(app),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
