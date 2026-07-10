import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/sms_import_loader.dart';
import 'package:spendsense/features/onboarding/sms_import_log.dart';
import 'package:spendsense/features/onboarding/sms_import_service.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_capture_providers.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';

final smsInboxGatewayProvider = Provider<SmsInboxGateway>((ref) {
  return PlatformSmsInboxGateway();
});

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
  late final DateTime _importSince = smsImportWindowStart(
    restoreSince: widget.since,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runImport());
  }

  Future<void> _runImport() async {
    if (_started) return;
    _started = true;

    smsImportLog(
      'SMS import screen started '
      '(restoreSince=${widget.since?.toIso8601String() ?? 'none'}, '
      'windowSince=${_importSince.toIso8601String()})',
    );

    final repository = ref.read(onboardingRepositoryProvider);
    final startIndex = await repository.importLastIndex();
    final completed = await repository.importCompleted();
    smsImportLog(
      'Saved import state: completed=$completed lastIndex=$startIndex',
    );

    if (completed) {
      smsImportLog(
        'Skipping import because it was already marked complete. '
        'New SMS parsers will not re-run until import is reset.',
      );
      final lastSync = await repository.lastSmsSyncAt();
      if (lastSync == null) {
        await repository.saveLastSmsSyncAt(DateTime.now());
      }
      widget.onComplete();
      return;
    }

    final permission = await ref.read(smsPermissionGatewayProvider).check();
    smsImportLog('SMS permission state: $permission');

    List<String> messages;
    if (permission == SmsPermissionState.granted) {
      try {
        messages = await loadSmsMessagesForImport(
          inbox: ref.read(smsInboxGatewayProvider),
          since: _importSince,
        );
      } catch (error, stackTrace) {
        smsImportLogError('Failed to load inbox messages', error, stackTrace);
        messages = const [];
      }
    } else {
      messages = const [];
      smsImportLog('SMS permission denied; continuing with manual entry only');
    }

    smsImportLog('Prepared ${messages.length} messages for processing');

    final importService = ref.read(smsImportServiceProvider);
    final result = await importService.importMessages(
      messages,
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

    smsImportLog(
      'SMS import screen finished: '
      'captured=${result.capturedCount} '
      'duplicates=${result.duplicateCount} '
      'ignored=${result.ignoredCount}',
    );

    await repository.saveLastSmsSyncAt(DateTime.now());

    if (mounted) widget.onComplete();
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
                  ? 'Importing the last $smsImportWindowMonths months of bank SMS…'
                  : 'Importing bank SMS since ${_formatDate(_importSince)}…',
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
