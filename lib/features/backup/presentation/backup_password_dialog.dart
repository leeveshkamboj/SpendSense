import 'package:flutter/material.dart';

class BackupPasswordDialog extends StatefulWidget {
  const BackupPasswordDialog({
    required this.title,
    required this.confirmLabel,
    super.key,
  });

  final String title;
  final String confirmLabel;

  @override
  State<BackupPasswordDialog> createState() => _BackupPasswordDialogState();
}

class _BackupPasswordDialogState extends State<BackupPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Password'),
        autofocus: true,
        onSubmitted: (_) => Navigator.of(context).pop(_controller.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

Future<String?> showBackupPasswordDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => BackupPasswordDialog(
      title: title,
      confirmLabel: confirmLabel,
    ),
  );
}
