import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/application.dart';
import '../models/application_event.dart';
import '../models/resume.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
import '../widgets/add_event_dialog.dart';
import '../widgets/application_timeline.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'add_application_screen.dart';

class ApplicationDetailsScreen extends StatefulWidget {
  final Application application;
  final Function(Application) onEdit;
  final Function(Application) onDelete;

  const ApplicationDetailsScreen({
    super.key,
    required this.application,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ApplicationDetailsScreen> createState() =>
      _ApplicationDetailsScreenState();
}

class _ApplicationDetailsScreenState extends State<ApplicationDetailsScreen> {
  late Application _application;
  bool _isDeleting = false;

  Resume? _linkedResume;
  bool _loadingResume = false;
  bool _openingResume = false;

  // ── Application Events state ──────────────────────────────────────────────
  List<ApplicationEvent> _events = [];
  bool _loadingEvents = true;
  String? _eventsError;

  @override
  void initState() {
    super.initState();
    _application = widget.application;
    if (_application.resumeId != null) _loadLinkedResume();
    _loadEvents();
  }

  Future<void> _loadLinkedResume() async {
    if (_application.resumeId == null) return;
    setState(() => _loadingResume = true);
    try {
      final resumes = await ApiService.getResumes();
      if (mounted) {
        setState(() {
          _linkedResume = resumes.firstWhere(
            (r) => r.id == _application.resumeId,
            orElse: () =>
                Resume(id: '', name: 'Unknown', fileName: '', uploadDate: ''),
          );
          _loadingResume = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingResume = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Application Events
  // ---------------------------------------------------------------------------

  Future<void> _loadEvents() async {
    setState(() {
      _loadingEvents = true;
      _eventsError = null;
    });
    try {
      final events = await ApiService.getEvents(_application.id);
      if (mounted) setState(() => _events = events);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _eventsError = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loadingEvents = false);
    }
  }

  void _handleAddEvent() {
    showDialog(
      context: context,
      builder: (_) => AddEventDialog(
        onSave: (eventType, eventDate, notes) async {
          final created = await ApiService.createEvent(
            _application.id,
            ApplicationEvent(
              id: '',
              applicationId: _application.id,
              eventType: eventType,
              eventDate: eventDate,
              notes: notes,
              createdAt: '',
            ),
          );
          if (mounted) {
            setState(() => _events.add(created));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event added')),
            );
          }
        },
      ),
    );
  }

  void _handleEditEvent(ApplicationEvent event) {
    showDialog(
      context: context,
      builder: (_) => AddEventDialog(
        event: event,
        onSave: (eventType, eventDate, notes) async {
          final updated = await ApiService.updateEvent(
            event.id,
            event.copyWith(
              eventType: eventType,
              eventDate: eventDate,
              notes: notes,
            ),
          );
          if (mounted) {
            setState(() {
              final idx = _events.indexWhere((e) => e.id == event.id);
              if (idx != -1) _events[idx] = updated;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event updated')),
            );
          }
        },
      ),
    );
  }

  void _handleDeleteEvent(ApplicationEvent event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
            'Delete the "${event.eventType}" event on ${event.eventDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.deleteEvent(event.id);
                if (mounted) {
                  setState(
                      () => _events.removeWhere((e) => e.id == event.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  final msg = e.toString().contains('connect')
                      ? 'Unable to connect to server'
                      : 'Failed to delete event';
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.errorContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openResume() async {
    if (_linkedResume == null || _linkedResume!.id.isEmpty) return;
    setState(() => _openingResume = true);
    try {
      final url = ApiService.getResumeFileUrl(_linkedResume!.id);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Open resume error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open resume')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingResume = false);
    }
  }

  void _handleEdit() async {
    final result = await Navigator.push<Application>(
      context,
      MaterialPageRoute(
        builder: (context) => AddApplicationScreen(application: _application),
      ),
    );
    if (result != null) {
      setState(() {
        _application = result;
        _linkedResume = null;
      });
      widget.onEdit(result);
      if (result.resumeId != null) _loadLinkedResume();
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteConfirmationDialog(
        companyName: _application.companyName,
        onConfirm: () async {
          setState(() => _isDeleting = true);
          try {
            await ApiService.deleteApplication(_application.id);
            widget.onDelete(_application);
            if (mounted) Navigator.pop(context);
          } catch (e) {
            debugPrint('Details delete error: $e');
            setState(() => _isDeleting = false);
            if (mounted) {
              final msg = e.toString().contains('connect')
                  ? 'Unable to connect to server'
                  : 'Failed to delete application';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(msg)));
            }
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = AppConstants.getStatusColor(_application.status);
    final nextAction = AppConstants.getNextAction(_application.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Application Details'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ───────────────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _application.companyName,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _application.role,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppBorderRadius.sm),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              _application.status,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Next action hint
                      if (nextAction.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.sm),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_forward_ios,
                                  size: 12, color: statusColor),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Next: $nextAction',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Timeline ─────────────────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ApplicationTimeline(
                    timeline: _application.timeline,
                    currentStatus: _application.status,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Application Events ────────────────────────────────────
              _buildEventsSection(theme),
              const SizedBox(height: AppSpacing.lg),

              // ── Details rows ──────────────────────────────────────────
              _buildDetailRow('Source', _application.source, Icons.source),
              _buildDetailRow(
                'Applied Date',
                DateFormatUtil.formatDate(_application.dateApplied),
                Icons.calendar_today,
              ),

              // Job link
              if (_application.jobLink.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: () => _launchUrl(_application.jobLink),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link, color: theme.colorScheme.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'View Job Posting',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _application.jobLink,
                                style: theme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.open_in_new,
                            color: theme.colorScheme.primary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],

              // ── Resume ───────────────────────────────────────────────
              if (_application.resumeId != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildResumeSection(theme),
              ],

              // Notes
              if (_application.notes != null &&
                  _application.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text('Notes',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Text(_application.notes!,
                      style: theme.textTheme.bodyMedium),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // ── Action buttons ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDeleting ? null : _handleEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isDeleting ? null : _handleDelete,
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
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

  // ---------------------------------------------------------------------------
  // Helper widgets
  // ---------------------------------------------------------------------------

  Widget _buildEventsSection(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Events',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _handleAddEvent,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Event'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Body
            if (_loadingEvents)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_eventsError != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: theme.colorScheme.error, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _eventsError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadEvents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_events.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'No events yet. Tap "Add Event" to log a recruitment milestone.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _events.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: AppSpacing.md),
                itemBuilder: (_, i) => _buildEventRow(_events[i], theme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventRow(ApplicationEvent event, ThemeData theme) {
    final color = AppConstants.getEventTypeColor(event.eventType);
    final icon = AppConstants.getEventTypeIcon(event.eventType);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coloured icon
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Type + date + notes
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.eventType,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                event.eventDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (event.notes != null && event.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    event.notes!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),

        // Edit / Delete actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              tooltip: 'Edit',
              visualDensity: VisualDensity.compact,
              onPressed: () => _handleEditEvent(event),
            ),
            IconButton(
              icon: Icon(Icons.delete,
                  size: 18, color: theme.colorScheme.error),
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
              onPressed: () => _handleDeleteEvent(event),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumeSection(ThemeData theme) {
    if (_loadingResume) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final resume = _linkedResume;
    if (resume == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume Used',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  resume.name,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                if (resume.fileName.isNotEmpty)
                  Text(
                    resume.fileName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _openingResume ? null : _openResume,
            icon: _openingResume
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.open_in_new, size: 16),
            label: const Text('View'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
