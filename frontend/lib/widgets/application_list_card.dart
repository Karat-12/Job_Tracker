import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import 'status_action_menu.dart';

class ApplicationListCard extends StatelessWidget {
  final Application application;
  final VoidCallback onDetails;
  final Function(String) onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ApplicationListCard({
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
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row 1: company / role + status badge ──────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.companyName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          application.role,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(
                          color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      application.status,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Row 2: current stage + next action ────────────────
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(AppConstants.getStatusIcon(application.status),
                        size: 13, color: statusColor),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Current Stage: ${application.status}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (nextAction.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const Text('·', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          'Next: $nextAction',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ── Row 3: source + applied date ──────────────────────
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    'Source: ${application.source}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Applied: ${DateFormatUtil.formatDate(application.dateApplied)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              // ── Notes preview ─────────────────────────────────────
              if (application.notes != null &&
                  application.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Text(
                    'Notes: ${application.notes}',
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // ── Action buttons ────────────────────────────────────
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        onPressed: onEdit,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Delete'),
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  StatusActionMenu(
                    application: application,
                    onStatusChanged: onStatusChanged,
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
