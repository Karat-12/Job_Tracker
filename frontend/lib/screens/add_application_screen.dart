import 'package:flutter/material.dart';
import '../models/application.dart';
import '../models/resume.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AddApplicationScreen extends StatefulWidget {
  final Application? application;

  const AddApplicationScreen({super.key, this.application});

  @override
  State<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends State<AddApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _sourceCtrl;
  late final TextEditingController _linkCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _notesCtrl;
  late String _status;
  String? _selectedResumeId;
  bool _isSaving = false;

  // Resumes loaded for the dropdown
  List<Resume> _resumes = [];
  bool _loadingResumes = true;

  bool get _canSubmit =>
      !_isSaving && (_formKey.currentState?.validate() ?? false);

  @override
  void initState() {
    super.initState();
    final app = widget.application;
    _companyCtrl = TextEditingController(text: app?.companyName ?? '');
    _roleCtrl = TextEditingController(text: app?.role ?? '');
    _sourceCtrl = TextEditingController(text: app?.source ?? '');
    _linkCtrl = TextEditingController(text: app?.jobLink ?? '');
    _dateCtrl = TextEditingController(
      text: app != null
          ? '${app.dateApplied.year}-'
              '${app.dateApplied.month.toString().padLeft(2, '0')}-'
              '${app.dateApplied.day.toString().padLeft(2, '0')}'
          : '',
    );
    _notesCtrl = TextEditingController(text: app?.notes ?? '');
    _status = app?.status ?? 'Applied';
    _selectedResumeId = app?.resumeId;
    _loadResumes();
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _roleCtrl.dispose();
    _sourceCtrl.dispose();
    _linkCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadResumes() async {
    try {
      final resumes = await ApiService.getResumes();
      if (mounted) {
        setState(() {
          _resumes = resumes;
          _loadingResumes = false;
          // Ensure selected ID still exists
          if (_selectedResumeId != null &&
              !resumes.any((r) => r.id == _selectedResumeId)) {
            _selectedResumeId = null;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingResumes = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Validators
  // ---------------------------------------------------------------------------

  String? _validateCompany(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Company name is required';
    if (v.length < 2) return 'Must be at least 2 characters';
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Date is required';
    try {
      final parts = value.trim().split('-');
      if (parts.length != 3) throw FormatException('bad parts');
      DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return null;
    } catch (_) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
  }

  String? _validateJobLink(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Enter a valid URL (e.g. https://example.com)';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'URL must start with http:// or https://';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _saveApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final dateParts = _dateCtrl.text.trim().split('-');
    final dateApplied = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    final application = Application(
      id: widget.application?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: _companyCtrl.text.trim(),
      role: _roleCtrl.text.trim(),
      source: _sourceCtrl.text.trim(),
      jobLink: _linkCtrl.text.trim(),
      dateApplied: dateApplied,
      status: _status,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      resumeId: _selectedResumeId,
    );

    setState(() => _isSaving = true);

    try {
      final saved = widget.application == null
          ? await ApiService.createApplication(application)
          : await ApiService.updateApplication(application);

      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      debugPrint('AddApplicationScreen save error: $e');
      if (mounted) {
        final message = e.toString().contains('connect')
            ? 'Unable to connect to server'
            : widget.application == null
            ? 'Failed to create application'
            : 'Failed to update application';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.application != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Application' : 'Add Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() {}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Company Name
              TextFormField(
                controller: _companyCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: _validateCompany,
              ),
              const SizedBox(height: AppSpacing.md),

              // Role
              TextFormField(
                controller: _roleCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Role *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: (v) => _validateRequired(v, 'Role'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Source
              TextFormField(
                controller: _sourceCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Source *',
                  hintText: 'e.g. LinkedIn, Company Site',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: (v) => _validateRequired(v, 'Source'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Job Link (optional)
              TextFormField(
                controller: _linkCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Job Link',
                  hintText: 'https://example.com/job (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: _validateJobLink,
              ),
              const SizedBox(height: AppSpacing.md),

              // Date Applied
              TextFormField(
                controller: _dateCtrl,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Date Applied *',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: _pickDate,
                    tooltip: 'Pick date',
                  ),
                ),
                validator: _validateDate,
              ),
              const SizedBox(height: AppSpacing.md),

              // Status
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: AppConstants.statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Applied'),
                decoration: InputDecoration(
                  labelText: 'Status *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: (v) => _validateRequired(v, 'Status'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Resume Used (optional)
              _buildResumeDropdown(),
              const SizedBox(height: AppSpacing.md),

              // Notes (optional)
              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              FilledButton(
                onPressed: _canSubmit ? _saveApplication : null,
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumeDropdown() {
    if (_loadingResumes) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Resume Used',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        child: const SizedBox(
          height: 20,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    if (_resumes.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Resume Used',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
        ),
        child: Text(
          'No resumes uploaded yet',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return DropdownButtonFormField<String?>(
      initialValue: _selectedResumeId,
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('None'),
        ),
        ..._resumes.map(
          (r) => DropdownMenuItem<String?>(value: r.id, child: Text(r.name)),
        ),
      ],
      onChanged: (v) => setState(() => _selectedResumeId = v),
      decoration: InputDecoration(
        labelText: 'Resume Used',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = () {
      try {
        final parts = _dateCtrl.text.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } catch (_) {}
      return now;
    }();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() {
        _dateCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }
}
