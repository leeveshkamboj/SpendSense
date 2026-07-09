import 'package:flutter/material.dart';
import 'package:spendsense/features/backup/domain/restore_verification_summary.dart';

class RestoreVerificationScreen extends StatelessWidget {
  const RestoreVerificationScreen({
    required this.summary,
    required this.onContinue,
    super.key,
  });

  final RestoreVerificationSummary summary;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restore verification')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Backup from ${_formatDate(summary.backupDate)} restored',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const Text('Restored cards'),
          const SizedBox(height: 8),
          if (summary.cardNicknames.isEmpty)
            const Text('No credit cards found in backup')
          else
            for (final nickname in summary.cardNicknames)
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(nickname),
              ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
