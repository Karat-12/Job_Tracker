import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import 'status_action_menu.dart';

class KanbanCard extends StatelessWidget {
  final Application application;
  final VoidCallback onDetails;
  final Function(String) onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KanbanCard({
    super.key,
    required this.application,
    required this.onDetails,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = AppConstants.getStatusColor(application.status);
    final nextAction = AppConstants.getNextAction(application.status);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        side: BorderSide(color: statusColor.withValues(alpha: 0.6), width: 1),
      ),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company + role
              Text(
                application.companyName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                application.role,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                DateFormatUtil.formatDateShort(application.dateApplied),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              // Current Stage + Next Action chip
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(AppConstants.getStatusIcon(application.status),
                            size: 11, color: statusColor),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            application.status,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (nextAction.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        nextAction,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit, size: 13),
                      label: const Text('Edit'),
                      onPressed: onEdit,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xs,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, size: 13),
                      label: const Text('Delete'),
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xs,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox(
                    width: 36,
                    child: StatusActionMenu(
                      application: application,
                      onStatusChanged: onStatusChanged,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
