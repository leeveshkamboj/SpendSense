import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/onboarding/sms_import_loader.dart';
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
  int _importWindowMonths = defaultSmsImportWindowMonths;
  DateTime? _importSince;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareAndRunImport());
  }

  Future<void> _prepareAndRunImport() async {
    final repository = ref.read(onboardingRepositoryProvider);
    _importWindowMonths = await repository.smsImportWindowMonths();
    _importSince = smsImportWindowStart(
      restoreSince: widget.since,
      months: _importWindowMonths,
    );
    if (mounted) {
      setState(() {});
    }
    await _runImport();
  }

  Future<void> _runImport() async {
    if (_started) return;
    _started = true;

    final importSince = _importSince;
    if (importSince == null) {
      return;
    }

    final repository = ref.read(onboardingRepositoryProvider);
    final startIndex = await repository.importLastIndex();
    final completed = await repository.importCompleted();

    if (completed) {
      final lastSync = await repository.lastSmsSyncAt();
      if (lastSync == null) {
        await repository.saveLastSmsSyncAt(DateTime.now());
      }
      widget.onComplete();
      return;
    }

    final permission = await ref.read(smsPermissionGatewayProvider).check();

    List<String> messages;
    if (permission == SmsPermissionState.granted) {
      try {
        messages = await loadSmsMessagesForImport(
          inbox: ref.read(smsInboxGatewayProvider),
          since: importSince,
        );
      } catch (_) {
        messages = const [];
      }
    } else {
      messages = const [];
    }

    final importService = ref.read(smsImportServiceProvider);
    await importService.importMessages(
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

    await repository.saveLastSmsSyncAt(DateTime.now());

    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final importSince = _importSince;

    return Scaffold(
      appBar: AppBar(title: const Text('Importing SMS')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.since == null
                  ? 'Importing the last $_importWindowMonths months of bank SMS…'
                  : 'Importing bank SMS since ${_formatDate(importSince ?? DateTime.now())}…',
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
