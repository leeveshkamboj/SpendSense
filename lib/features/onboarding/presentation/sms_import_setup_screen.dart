import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/sms_import_loader.dart';

const smsImportWindowOptions = <int>[3, 6, 12, 24];

class SmsImportSetupScreen extends ConsumerStatefulWidget {
  const SmsImportSetupScreen({
    required this.onContinue,
    this.onSkip,
    super.key,
  });

  final VoidCallback onContinue;
  final VoidCallback? onSkip;

  @override
  ConsumerState<SmsImportSetupScreen> createState() =>
      _SmsImportSetupScreenState();
}

class _SmsImportSetupScreenState extends ConsumerState<SmsImportSetupScreen> {
  int _selectedMonths = defaultSmsImportWindowMonths;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS import')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How far back should SpendSense scan your inbox for bank SMS?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'A longer window imports more history but takes longer on first launch.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final months in smsImportWindowOptions)
                ChoiceChip(
                  label: Text('$months months'),
                  selected: _selectedMonths == months,
                  onSelected: (_) => setState(() => _selectedMonths = months),
                ),
            ],
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _saving ? null : _continue,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Import last $_selectedMonths months'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _saving
                ? null
                : () {
                    if (widget.onSkip != null) {
                      widget.onSkip!();
                      return;
                    }
                    _continue(skipImport: true);
                  },
            child: const Text('Skip import'),
          ),
        ],
      ),
    );
  }

  Future<void> _continue({bool skipImport = false}) async {
    setState(() => _saving = true);
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      await repository.saveSmsImportWindowMonths(_selectedMonths);
      if (skipImport) {
        await repository.saveImportProgress(lastIndex: 0, completed: true);
        await repository.saveLastSmsSyncAt(DateTime.now());
      }
      widget.onContinue();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
