import 'package:flutter/material.dart';
import '../models/timeline_event.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

/// Displays the chronological list of status-change events for one application.
///
/// If the timeline list is empty (e.g. legacy document with no history)
/// it falls back to showing just the current status as a single node.
class ApplicationTimeline extends StatelessWidget {
  final List<TimelineEvent> timeline;
  final String currentStatus;

  const ApplicationTimeline({
    super.key,
    required this.timeline,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (timeline.isEmpty)
          _buildSingleEvent(context, currentStatus)
        else
          ...timeline.asMap().entries.map(
                (entry) => _buildEventRow(
                  context,
                  entry.value,
                  isLast: entry.key == timeline.length - 1,
                ),
              ),
      ],
    );
  }

  /// Fallback for applications with no timeline data.
  Widget _buildSingleEvent(BuildContext context, String status) {
    final color = AppConstants.getStatusColor(status);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDot(color, isLast: true),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              status,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventRow(
    BuildContext context,
    TimelineEvent event, {
    required bool isLast,
  }) {
    final theme = Theme.of(context);
    final color = AppConstants.getStatusColor(event.title);
    final dt = event.dateTime;
    final dateLabel = dt != null
        ? DateFormatUtil.formatDate(dt)
        : event.timestamp;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + vertical line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _buildDot(color, isLast: isLast),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outline.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Event text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppConstants.getStatusIcon(event.title),
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, {required bool isLast}) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}
