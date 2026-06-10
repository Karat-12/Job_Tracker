import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String companyName;

  /// Called when the user confirms deletion. The dialog is already dismissed
  /// before this callback fires — do not call Navigator.pop() inside it.
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.companyName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Application'),
      content: Text(
        'Are you sure you want to delete the application for $companyName?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.tonal(
          onPressed: () {
            Navigator.pop(context); // Dismiss dialog first
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
