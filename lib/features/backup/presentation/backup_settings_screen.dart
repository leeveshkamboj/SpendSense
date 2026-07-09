import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/backup/presentation/backup_password_dialog.dart';
import 'package:spendsense/features/backup/data/backup_providers.dart';
import 'package:spendsense/features/backup/data/backup_service.dart';
import 'package:spendsense/features/backup/domain/backup_exception.dart';

class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() =>
      _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends ConsumerState<BackupSettingsScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final autoBackupFailure = ref.watch(autoBackupFailureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Backups are always password-protected .ssb files. '
            'There is no unencrypted export.',
          ),
          if (autoBackupFailure != null) ...[
            const SizedBox(height: 16),
            MaterialBanner(
              content: Text('Automatic backup failed: $autoBackupFailure'),
              actions: const [SizedBox.shrink()],
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : () => _exportBackup(context),
            child: const Text('Export backup'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : () => _restoreBackup(context),
            child: const Text('Restore from backup'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final password = await _promptForPassword(
      context,
      title: 'Export backup',
      confirmLabel: 'Continue',
    );
    if (password == null || password.isEmpty) {
      return;
    }

    setState(() => _busy = true);
    final result = await ref
        .read(backupServiceProvider)
        .exportBackup(password: password);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    _showResult(context, result);
  }

  Future<void> _restoreBackup(BuildContext context) async {
    final service = ref.read(backupServiceProvider);
    final backupFilePath = await service.pickBackupFile();
    if (backupFilePath == null) {
      return;
    }

    final password = await _promptForPassword(
      context,
      title: 'Restore from backup',
      confirmLabel: 'Continue',
    );
    if (password == null || password.isEmpty) {
      return;
    }

    setState(() => _busy = true);
    final result = await service.restoreBackup(
      backupFilePath: backupFilePath,
      password: password,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    _showResult(context, result);
  }

  Future<String?> _promptForPassword(
    BuildContext context, {
    required String title,
    required String confirmLabel,
  }) {
    return showBackupPasswordDialog(
      context,
      title: title,
      confirmLabel: confirmLabel,
    );
  }

  void _showResult(BuildContext context, BackupActionResult result) {
    switch (result) {
      case BackupActionSuccess(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      case BackupActionFailure(:final error):
        final message = switch (error) {
          BackupWrongPasswordException(:final fileName) =>
            'Wrong password for $fileName',
          BackupCorruptFileException(:final fileName, :final reason) =>
            'Could not read $fileName${reason == null ? '' : ': $reason'}',
          _ => 'Backup failed: $error',
        };
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup failed'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      case BackupActionCancelled():
        return;
    }
  }
}
