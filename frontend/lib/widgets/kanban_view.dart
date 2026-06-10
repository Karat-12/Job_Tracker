import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/constants.dart';
import 'kanban_card.dart';

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

  List<Application> _getAppsByStatus(String status) {
    return applications.where((app) => app.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppConstants.statuses
            .map((status) => _buildColumn(context, status))
            .toList(),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String status) {
    final apps = _getAppsByStatus(status);
    final statusColor = AppConstants.getStatusColor(status);

    return Container(
      width: 300,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withOpacity(0.1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              color: statusColor.withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    apps.length.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<Application>(
              onAcceptWithDetails: (details) {
                final app = details.data;
                if (app.status != status) {
                  onStatusChanged(app, status);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  color: candidateData.isNotEmpty
                      ? statusColor.withOpacity(0.15)
                      : Colors.transparent,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return Draggable<Application>(
                        data: app,
                        feedback: Material(
                          child: Container(
                            width: 280,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: KanbanCard(
                              application: app,
                              onDetails: () => onDetails(app),
                              onStatusChanged: (newStatus) =>
                                  onStatusChanged(app, newStatus),
                              onEdit: () => onEdit(app),
                              onDelete: () => onDelete(app),
                            ),
                          ),
                        ),
                        child: KanbanCard(
                          application: app,
                          onDetails: () => onDetails(app),
                          onStatusChanged: (newStatus) =>
                              onStatusChanged(app, newStatus),
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
