import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/sms_import_filter.dart';
import 'package:spendsense/features/onboarding/sms_import_service.dart';
import 'package:spendsense/features/sms_capture/sms_capture_providers.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';
import 'package:spendsense/features/location/location_providers.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';

final smsImportServiceProvider = Provider<SmsImportService>((ref) {
  return SmsImportService(ref.watch(smsCaptureServiceProvider));
});

class SmsImportScreen extends ConsumerStatefulWidget {
  const SmsImportScreen({
    required this.onComplete,
    this.since,
    super.key,
  });

  final VoidCallback onComplete;
  final DateTime? since;

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  double _progress = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runImport());
  }

  Future<void> _runImport() async {
    if (_started) return;
    _started = true;

    final permission = await ref.read(smsPermissionGatewayProvider).request();
    await _maybeExplainLocation(context);
    final repository = ref.read(onboardingRepositoryProvider);
    final startIndex = await repository.importLastIndex();
    final completed = await repository.importCompleted();
    if (completed) {
      widget.onComplete();
      return;
    }

    final sampleMessages = permission == SmsPermissionState.granted
        ? _messagesToImport()
        : <String>[];

    final importService = ref.read(smsImportServiceProvider);
    await importService.importMessages(
      sampleMessages,
      startIndex: startIndex,
      onProgress: (processed, total) async {
        if (!mounted) return;
        setState(() => _progress = total == 0 ? 1 : processed / total);
        await repository.saveImportProgress(
          lastIndex: processed,
          completed: processed == total,
        );
      },
    );

    if (mounted) widget.onComplete();
  }

  Future<void> _maybeExplainLocation(BuildContext context) async {
    final service = ref.read(locationCaptureServiceProvider);
    final decision = await service.requestForCapture();
    if (!mounted || decision != LocationCaptureDecision.showExplanation) {
      return;
    }

    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add transaction location?'),
        content: const Text(
          'SpendSense can attach your location when a bank SMS is captured. '
          'This helps you remember where a purchase happened.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    await service.completeExplanationFlow();
    if (!mounted) {
      return;
    }
    if (proceed == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location capture skipped')),
      );
    }
  }

  List<String> _messagesToImport() {
    final messages = _sampleHistoricalMessages();
    final since = widget.since;
    if (since == null) {
      return messages;
    }
    return filterSmsSince(messages, since: since);
  }

  List<String> _sampleHistoricalMessages() {
    return [
      'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.',
      'Dear UPI user A/C X0428 debited by 25000.00 on 09-07-26 to MERCHANT Ref 987654',
      'Rs.199.15 spent on your SBI Credit Card ending with 8401 at ZOMATO on 09-07-26 Ref 123456',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importing SMS')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.since == null
                  ? 'Importing the last 12 months of bank SMS…'
                  : 'Importing bank SMS received since ${_formatDate(widget.since!)}…',
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 12),
            Text('${(_progress * 100).round()}%'),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
