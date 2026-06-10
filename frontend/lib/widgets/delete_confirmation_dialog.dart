import 'package:flutter/material.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String companyName;
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
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
