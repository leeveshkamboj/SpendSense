import 'package:flutter/material.dart';
import 'package:spendsense/features/backup/presentation/backup_settings_screen.dart';

enum DeleteAllChoice { cancel, backupFirst, deleteAnyway }

Future<DeleteAllChoice?> showDeleteAllDataDialog(BuildContext context) {
  return showDialog<DeleteAllChoice>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete all data?'),
      content: const Text(
        'This permanently removes all cards, transactions, budgets, and '
        'settings from this device. Create a backup first?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(DeleteAllChoice.cancel),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(DeleteAllChoice.backupFirst),
          child: const Text('Back up first'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(DeleteAllChoice.deleteAnyway),
          child: const Text('Delete anyway'),
        ),
      ],
    ),
  );
}

Future<bool> confirmDeleteAllAnyway(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete all data'),
      content: const Text(
        'This cannot be undone. All local SpendSense data will be removed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<void> openBackupSettings(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const BackupSettingsScreen(),
    ),
  );
}
