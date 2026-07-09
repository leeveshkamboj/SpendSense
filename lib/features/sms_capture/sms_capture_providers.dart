import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/accounts/data/bank_account_providers.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_providers.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/sms_capture/capture_notification_provider.dart';
import 'package:spendsense/features/sms_capture/sms_capture_service.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';

final smsCaptureServiceProvider = Provider<SmsCaptureService>((ref) {
  return SmsCaptureService(
    creditCards: ref.watch(creditCardRepositoryProvider),
    cardTransactions: ref.watch(cardTransactionRepositoryProvider),
    bankAccounts: ref.watch(bankAccountRepositoryProvider),
    bankAccountTransactions: ref.watch(bankAccountTransactionRepositoryProvider),
    onCaptured: (event) {
      ref.read(captureNotificationProvider.notifier).state = event;
    },
    onManualAddSuggested: (sms) {
      ref.read(manualAddSuggestionProvider.notifier).state = sms;
    },
  );
});

final manualAddSuggestionProvider = StateProvider<String?>((ref) => null);
