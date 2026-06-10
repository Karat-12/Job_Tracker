import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/constants.dart';

class StatusActionMenu extends StatelessWidget {
  final Application application;
  final Function(String) onStatusChanged;

  const StatusActionMenu({
    super.key,
    required this.application,
    required this.onStatusChanged,
  });

  List<String> _getAvailableStatusTransitions() {
    final currentStatus = application.status;
    final allStatuses = AppConstants.statuses;

    // Allow transition to any status except current
    return allStatuses.where((s) => s != currentStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final availableStatuses = _getAvailableStatusTransitions();

    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return availableStatuses.map((String status) {
          final statusColor = AppConstants.getStatusColor(status);
          return PopupMenuItem<String>(
            value: status,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(status),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String status) {
        if (status != application.status) {
          onStatusChanged(status);
        }
      },
      icon: const Icon(Icons.more_vert),
      tooltip: 'Change Status',
    );
  }
}
