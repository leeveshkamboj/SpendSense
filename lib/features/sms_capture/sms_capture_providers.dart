import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/linking/data/linking_providers.dart';
import 'package:spendsense/features/location/data/sms_location_capture.dart';
import 'package:spendsense/features/location/location_providers.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/features/sms_capture/capture_notification_provider.dart';
import 'package:spendsense/features/sms_capture/data/capture_notification_service.dart';
import 'package:spendsense/features/sms_capture/data/seen_sms_repository.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final captureNotificationServiceProvider =
    Provider<CaptureNotificationService>((ref) {
  throw UnimplementedError(
    'captureNotificationServiceProvider must be overridden in main()',
  );
});

final smsLocationCaptureProvider = Provider<SmsLocationCapture>((ref) {
  return SmsLocationCapture(
    permissionGateway: ref.watch(locationPermissionGatewayProvider),
    geolocation: ref.watch(geolocationServiceProvider),
  );
});

final smsCaptureServiceProvider = Provider<SmsCaptureService>((ref) {
  final captureNotifications = ref.watch(captureNotificationServiceProvider);
  final locationCapture = ref.watch(smsLocationCaptureProvider);
  return SmsCaptureService(
    creditCards: ref.watch(creditCardRepositoryProvider),
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
    bankAccounts: ref.watch(bankAccountRepositoryProvider),
    bankAccountTransactions: ref.watch(bankAccountTransactionRepositoryProvider),
    merchants: ref.watch(merchantRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
    linking: ref.watch(linkingRepositoryProvider),
    seenSms: SeenSmsRepository(ref.watch(databaseProvider)),
    onCaptured: (event) {
      ref.read(captureNotificationProvider.notifier).state = event;
      captureNotifications.showCapture(event);
    },
    onManualAddSuggested: (sms) {
      ref.read(manualAddSuggestionProvider.notifier).state = sms;
      captureNotifications.showManualAddSuggestion();
    },
    resolveLocation: locationCapture.captureSerialized,
  );
});

final manualAddSuggestionProvider = StateProvider<String?>((ref) => null);
