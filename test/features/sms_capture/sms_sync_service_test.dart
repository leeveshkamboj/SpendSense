import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';
import 'package:spendsense/features/sms_capture/data/sms_inbox_gateway.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_sync_service.dart';

void main() {
  group('SmsSyncService', () {
    late AppDatabase database;
    late OnboardingRepository settings;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      settings = OnboardingRepository(database);
      await settings.importLastIndex();
      await settings.markOnboardingComplete();
      await settings.saveImportProgress(lastIndex: 10, completed: true);
    });

    tearDown(() async {
      await database.close();
    });

    test('establishes baseline for completed imports without prior sync', () async {
      final service = SmsSyncService.testing(
        inbox: InMemorySmsInboxGateway(const []),
        processor: (_) async => SmsCaptureResult.ignored,
        settings: settings,
        permissionGateway: _grantedPermissionGateway(),
      );

      final result = await service.syncNewMessages(
        now: DateTime(2026, 7, 10, 12),
      );

      expect(result, isA<SkippedSmsSyncResult>());
      expect(
        (result as SkippedSmsSyncResult).reason,
        SmsSyncSkipReason.baselineEstablished,
      );
      expect(
        await settings.lastSmsSyncAt(),
        DateTime(2026, 7, 10, 12),
      );
    });

    test('reprocesses lookback SMS and advances past newer messages', () async {
      final lastSync = DateTime(2026, 7, 10, 12);
      await settings.saveLastSmsSyncAt(lastSync);

      final inbox = InMemorySmsInboxGateway([
        SmsInboxMessage(
          sender: 'HDFCBK',
          body: 'old message',
          receivedAt: lastSync,
        ),
        SmsInboxMessage(
          sender: 'HDFCBK',
          body: 'new message',
          receivedAt: lastSync.add(const Duration(minutes: 1)),
        ),
      ]);

      final processed = <String>[];
      final service = SmsSyncService.testing(
        inbox: inbox,
        processor: (sms) async {
          processed.add(sms);
          return SmsCaptureResult.ignored;
        },
        settings: settings,
        permissionGateway: _grantedPermissionGateway(),
      );

      final result = await service.syncNewMessages();

      expect(result, isA<ProcessedSmsSyncResult>());
      final processedResult = result as ProcessedSmsSyncResult;
      expect(processedResult.messageCount, 2);
      expect(processed, ['old message', 'new message']);
      expect(
        await settings.lastSmsSyncAt(),
        lastSync.add(const Duration(minutes: 1)),
      );
    });

    test('reprocesses late MMS/RCS bodies inside the lookback window', () async {
      final lastSync = DateTime(2026, 7, 10, 12);
      await settings.saveLastSmsSyncAt(lastSync);

      final rcsBody =
          'Rs.400.00 spent on your SBI Credit Card ending with 8401 '
          'at RadheyCollection on 02-12-25 via UPI (Ref No. 533604324624). '
          'Trxn. not done by you? Report at https://sbicard.com/Dispute';

      final inbox = InMemorySmsInboxGateway([
        SmsInboxMessage(
          sender: 'SBI Cards',
          body: rcsBody,
          receivedAt: lastSync.subtract(const Duration(minutes: 5)),
          channel: InboxMessageChannel.rcsMms,
        ),
        SmsInboxMessage(
          sender: 'HDFCBK',
          body: 'later sms',
          receivedAt: lastSync.add(const Duration(minutes: 1)),
        ),
      ]);

      final processed = <String>[];
      final service = SmsSyncService.testing(
        inbox: inbox,
        processor: (sms) async {
          processed.add(sms);
          return SmsCaptureResult.ignored;
        },
        settings: settings,
        permissionGateway: _grantedPermissionGateway(),
      );

      final result = await service.syncNewMessages();

      expect(result, isA<ProcessedSmsSyncResult>());
      expect((result as ProcessedSmsSyncResult).messageCount, 2);
      expect(processed, [rcsBody, 'later sms']);
      expect(
        await settings.lastSmsSyncAt(),
        lastSync.add(const Duration(minutes: 1)),
      );
    });

    test('skips sync when SMS permission is denied', () async {
      await settings.saveLastSmsSyncAt(DateTime(2026, 7, 10, 12));

      final service = SmsSyncService.testing(
        inbox: InMemorySmsInboxGateway(const []),
        processor: (_) async => SmsCaptureResult.ignored,
        settings: settings,
        permissionGateway: _deniedPermissionGateway(),
      );

      final result = await service.syncNewMessages();

      expect(result, isA<SkippedSmsSyncResult>());
      expect(
        (result as SkippedSmsSyncResult).reason,
        SmsSyncSkipReason.permissionDenied,
      );
    });
  });
}

class _GrantedPermissionGateway implements SmsPermissionGateway {
  @override
  Future<SmsPermissionState> check() async => SmsPermissionState.granted;

  @override
  Future<SmsPermissionState> request() async => SmsPermissionState.granted;
}

class _DeniedPermissionGateway implements SmsPermissionGateway {
  @override
  Future<SmsPermissionState> check() async => SmsPermissionState.denied;

  @override
  Future<SmsPermissionState> request() async => SmsPermissionState.denied;
}

SmsPermissionGateway _grantedPermissionGateway() => _GrantedPermissionGateway();

SmsPermissionGateway _deniedPermissionGateway() => _DeniedPermissionGateway();
