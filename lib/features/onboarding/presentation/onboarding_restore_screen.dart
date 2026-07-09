import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/backup/data/backup_providers.dart';
import 'package:spendsense/features/backup/data/backup_service.dart';
import 'package:spendsense/features/backup/data/restore_verification.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/backup/domain/backup_metadata.dart';
import 'package:spendsense/features/backup/domain/restore_verification_summary.dart';
import 'package:spendsense/features/backup/presentation/backup_password_dialog.dart';
import 'package:spendsense/features/backup/presentation/restore_verification_screen.dart';

class OnboardingRestoreScreen extends ConsumerStatefulWidget {
  const OnboardingRestoreScreen({
    required this.onComplete,
    super.key,
  });

  final ValueChanged<RestoreVerificationSummary> onComplete;

  @override
  ConsumerState<OnboardingRestoreScreen> createState() =>
      _OnboardingRestoreScreenState();
}

class _OnboardingRestoreScreenState extends ConsumerState<OnboardingRestoreScreen> {
  RestoreVerificationSummary? _summary;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    if (summary != null) {
      return RestoreVerificationScreen(
        summary: summary,
        onContinue: () => widget.onComplete(summary),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Restore from backup')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose an encrypted SpendSense backup (.ssb) and enter '
              'your password to restore your data.',
            ),
            const Spacer(),
            FilledButton(
              onPressed: _busy ? null : _startRestore,
              child: const Text('Choose backup file'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRestore() async {
    final service = ref.read(backupServiceProvider);
    final backupFilePath = await service.pickBackupFile();
    if (backupFilePath == null || !mounted) {
      return;
    }

    final password = await showBackupPasswordDialog(
      context,
      title: 'Restore from backup',
      confirmLabel: 'Restore',
    );
    if (password == null || password.isEmpty || !mounted) {
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

    switch (result) {
      case BackupActionSuccess(:final metadata):
        if (metadata == null) {
          _showError('Backup restored but metadata was missing');
          return;
        }
        final summary = await loadRestoreVerificationSummary(
          ref.read(creditCardRepositoryProvider),
          metadata,
        );
        if (!mounted) {
          return;
        }
        setState(() => _summary = summary);
      case BackupActionFailure(:final error):
        _showError('$error');
      case BackupActionCancelled():
        return;
    }
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
