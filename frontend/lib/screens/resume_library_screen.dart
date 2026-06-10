import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/resume.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ResumeLibraryScreen extends StatefulWidget {
  const ResumeLibraryScreen({super.key});

  @override
  State<ResumeLibraryScreen> createState() => _ResumeLibraryScreenState();
}

class _ResumeLibraryScreenState extends State<ResumeLibraryScreen> {
  List<Resume> _resumes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final resumes = await ApiService.getResumes();
      if (mounted) setState(() => _resumes = resumes);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Upload
  // ---------------------------------------------------------------------------

  void _handleUpload() async {
    // Pick PDF file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final defaultName = result.files.single.name
        .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');

    if (!mounted) return;
    _showResumeFormDialog(
      title: 'Upload Resume',
      initialName: defaultName,
      onSave: (name, notes) async {
        try {
          final resume = await ApiService.uploadResume(
            name: name,
            filePath: filePath,
            notes: notes.isEmpty ? null : notes,
          );
          if (mounted) {
            setState(() => _resumes.add(resume));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resume uploaded successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            final msg = e.toString().contains('connect')
                ? 'Unable to connect to server'
                : 'Failed to upload resume';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Edit
  // ---------------------------------------------------------------------------

  void _handleEdit(Resume resume) {
    _showResumeFormDialog(
      title: 'Edit Resume',
      initialName: resume.name,
      initialNotes: resume.notes ?? '',
      onSave: (name, notes) async {
        try {
          final updated = await ApiService.updateResume(
            resume.id,
            name: name,
            notes: notes.isEmpty ? null : notes,
          );
          if (mounted) {
            setState(() {
              final idx = _resumes.indexWhere((r) => r.id == updated.id);
              if (idx != -1) _resumes[idx] = updated;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Resume updated successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            final msg = e.toString().contains('connect')
                ? 'Unable to connect to server'
                : 'Failed to update resume';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  void _handleDelete(Resume resume) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text('Delete "${resume.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.deleteResume(resume.id);
                if (mounted) {
                  setState(
                      () => _resumes.removeWhere((r) => r.id == resume.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Resume deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  final msg = e.toString().contains('connect')
                      ? 'Unable to connect to server'
                      : 'Failed to delete resume';
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

  // ---------------------------------------------------------------------------
  // View resume PDF
  // ---------------------------------------------------------------------------

  Future<void> _viewResume(Resume resume) async {
    try {
      final url = ApiService.getResumeFileUrl(resume.id);
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open resume')),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Form dialog
  // ---------------------------------------------------------------------------

  void _showResumeFormDialog({
    required String title,
    required String initialName,
    String initialNotes = '',
    required Future<void> Function(String name, String notes) onSave,
  }) {
    final nameCtrl = TextEditingController(text: initialName);
    final notesCtrl = TextEditingController(text: initialNotes);
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Resume Name *',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.md),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.md),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => saving = true);
                          await onSave(
                            nameCtrl.text.trim(),
                            notesCtrl.text.trim(),
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Resume Library'), elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleUpload,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload PDF'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off,
                        size: 64,
                        color: theme.colorScheme.error.withValues(alpha: 0.8)),
                    const SizedBox(height: AppSpacing.lg),
                    Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _resumes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf,
                        size: 80,
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No Resumes Yet',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Upload your resume PDFs to link them\nto job applications',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                80, // space for FAB
              ),
              itemCount: _resumes.length,
              itemBuilder: (context, index) =>
                  _buildResumeCard(_resumes[index], theme),
            ),
    );
  }

  Widget _buildResumeCard(Resume resume, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.picture_as_pdf,
                color: theme.colorScheme.primary, size: 36),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resume.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    resume.fileName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (resume.uploadDate.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Uploaded: ${resume.uploadDate}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (resume.notes != null && resume.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      resume.notes!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 20),
                  tooltip: 'View PDF',
                  onPressed: () => _viewResume(resume),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Edit',
                  onPressed: () => _handleEdit(resume),
                ),
                IconButton(
                  icon: Icon(Icons.delete,
                      size: 20, color: theme.colorScheme.error),
                  tooltip: 'Delete',
                  onPressed: () => _handleDelete(resume),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
