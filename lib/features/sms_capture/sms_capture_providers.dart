import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/linking/data/linking_providers.dart';
import 'package:spendsense/features/location/data/sms_location_capture.dart';
import 'package:spendsense/features/location/location_providers.dart';
import 'package:spendsense/features/merchants/data/merchant_providers.dart';
import 'package:spendsense/features/sms_capture/capture_notification_provider.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/tags/data/tag_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final smsLocationCaptureProvider = Provider<SmsLocationCapture>((ref) {
  return SmsLocationCapture(
    permissionGateway: ref.watch(locationPermissionGatewayProvider),
    geolocation: ref.watch(geolocationServiceProvider),
  );
});

final smsCaptureServiceProvider = Provider<SmsCaptureService>((ref) {
  final locationCapture = ref.watch(smsLocationCaptureProvider);
  return SmsCaptureService(
    creditCards: ref.watch(creditCardRepositoryProvider),
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
    bankAccounts: ref.watch(bankAccountRepositoryProvider),
    bankAccountTransactions: ref.watch(bankAccountTransactionRepositoryProvider),
    merchants: ref.watch(merchantRepositoryProvider),
    tags: ref.watch(tagRepositoryProvider),
    linking: ref.watch(linkingRepositoryProvider),
    onCaptured: (event) {
      ref.read(captureNotificationProvider.notifier).state = event;
    },
    onManualAddSuggested: (sms) {
      ref.read(manualAddSuggestionProvider.notifier).state = sms;
    },
    resolveLocation: locationCapture.captureSerialized,
  );
});

final manualAddSuggestionProvider = StateProvider<String?>((ref) => null);
