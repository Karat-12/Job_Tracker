import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/application.dart';
import '../models/resume.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';
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

  @override
  void initState() {
    super.initState();
    _application = widget.application;
    if (_application.resumeId != null) _loadLinkedResume();
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
