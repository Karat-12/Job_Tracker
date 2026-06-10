import 'package:flutter/material.dart';
import '../models/application.dart';
import '../utils/constants.dart';

class AddApplicationScreen extends StatefulWidget {
  final Application? application;

  const AddApplicationScreen({super.key, this.application});

  @override
  State<AddApplicationScreen> createState() => _AddApplicationScreenState();
}

class _AddApplicationScreenState extends State<AddApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyCtrl;
  late TextEditingController _roleCtrl;
  late TextEditingController _sourceCtrl;
  late TextEditingController _linkCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _notesCtrl;
  late String _status;

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
          ? '${app.dateApplied.year}-${app.dateApplied.month.toString().padLeft(2, '0')}-${app.dateApplied.day.toString().padLeft(2, '0')}'
          : '',
    );
    _notesCtrl = TextEditingController(text: app?.notes ?? '');
    _status = app?.status ?? 'Applied';
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

  void _saveApplication() {
    if (!_formKey.currentState!.validate()) return;

    final dateStr = _dateCtrl.text;
    final dateParts = dateStr.split('-');
    final dateApplied = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );

    final newApp = Application(
      id:
          widget.application?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      companyName: _companyCtrl.text,
      role: _roleCtrl.text,
      source: _sourceCtrl.text,
      jobLink: _linkCtrl.text,
      dateApplied: dateApplied,
      status: _status,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );

    Navigator.pop(context, newApp);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.application != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Application' : 'Add Application'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyCtrl,
                decoration: InputDecoration(
                  labelText: 'Company Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Company name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _roleCtrl,
                decoration: InputDecoration(
                  labelText: 'Role *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Role is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _sourceCtrl,
                decoration: InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _linkCtrl,
                decoration: InputDecoration(
                  labelText: 'Job Link',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _dateCtrl,
                decoration: InputDecoration(
                  labelText: 'Date Applied (YYYY-MM-DD)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date is required';
                  }
                  try {
                    final parts = value.split('-');
                    if (parts.length != 3) throw Exception();
                    DateTime(
                      int.parse(parts[0]),
                      int.parse(parts[1]),
                      int.parse(parts[2]),
                    );
                    return null;
                  } catch (e) {
                    return 'Invalid date format';
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: AppConstants.statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v ?? 'Applied'),
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: _saveApplication,
                child: Text(isEditing ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
