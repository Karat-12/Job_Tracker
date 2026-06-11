import 'package:flutter/material.dart';
import '../models/application_event.dart';
import '../utils/constants.dart';

/// Dialog for creating or editing an [ApplicationEvent].
///
/// On save, calls [onSave] with the chosen [eventType], [eventDate],
/// and optional [notes]. The caller is responsible for the API call.
class AddEventDialog extends StatefulWidget {
  /// If non-null the dialog is in "edit" mode and pre-fills fields.
  final ApplicationEvent? event;

  /// Called with (eventType, eventDate "YYYY-MM-DD", notes) when the user
  /// confirms. The callback is async so the dialog can show a spinner.
  final Future<void> Function(String eventType, String eventDate, String? notes)
      onSave;

  const AddEventDialog({
    super.key,
    this.event,
    required this.onSave,
  });

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _eventType;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _eventType = widget.event?.eventType ?? AppConstants.eventTypes.first;
    _dateCtrl = TextEditingController(text: widget.event?.eventDate ?? '');
    _notesCtrl = TextEditingController(text: widget.event?.notes ?? '');
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Date is required';
    try {
      DateTime.parse(value.trim());
      return null;
    } catch (_) {
      return 'Enter a valid date (YYYY-MM-DD)';
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _eventType,
        _dateCtrl.text.trim(),
        _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Error is handled by the caller; just re-enable the button.
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    DateTime initial = now;
    try {
      if (_dateCtrl.text.isNotEmpty) initial = DateTime.parse(_dateCtrl.text);
    } catch (_) {}

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-'
            '${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Event' : 'Add Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Event type ──────────────────────────────────────────
              DropdownButtonFormField<String>(
                value: _eventType,
                decoration: InputDecoration(
                  labelText: 'Event Type *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                items: AppConstants.eventTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            Icon(
                              AppConstants.getEventTypeIcon(t),
                              size: 16,
                              color: AppConstants.getEventTypeColor(t),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(t),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _eventType = v!),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Event date ──────────────────────────────────────────
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Event Date *',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: _saving ? null : _pickDate,
                    tooltip: 'Pick date',
                  ),
                ),
                validator: _validateDate,
                onTap: _saving ? null : _pickDate,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Notes ───────────────────────────────────────────────
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                enabled: !_saving,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              ),

              // ── Event type colour preview ────────────────────────────
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    AppConstants.getEventTypeIcon(_eventType),
                    color: AppConstants.getEventTypeColor(_eventType),
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _eventType,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppConstants.getEventTypeColor(_eventType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _handleSave,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}
