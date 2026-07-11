import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_providers.dart';
import 'package:spendsense/features/dashboard/data/dashboard_refresh.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_gate.dart';
import 'package:spendsense/features/transactions/data/card_transaction_providers.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

class WidgetQuickAddSaveRequest {
  const WidgetQuickAddSaveRequest({
    required this.kind,
    required this.amountText,
    required this.merchantText,
    this.cardId,
  });

  final String kind;
  final String amountText;
  final String merchantText;
  final int? cardId;
}

sealed class WidgetQuickAddSaveResult {
  const WidgetQuickAddSaveResult();
}

final class WidgetQuickAddSaveSuccess extends WidgetQuickAddSaveResult {
  const WidgetQuickAddSaveSuccess();
}

final class WidgetQuickAddSaveFailure extends WidgetQuickAddSaveResult {
  const WidgetQuickAddSaveFailure(this.message);

  final String message;
}

typedef WidgetQuickAddReader = T Function<T>(ProviderListenable<T> provider);

Future<WidgetQuickAddSaveResult> saveWidgetQuickAdd({
  required WidgetQuickAddReader read,
  required WidgetRef? widgetRef,
  required WidgetQuickAddSaveRequest request,
}) async {
  final onboardingDone =
      await read(onboardingRepositoryProvider).isOnboardingComplete();
  if (!onboardingDone) {
    return const WidgetQuickAddSaveFailure('Finish setup in SpendSense first');
  }

  final cards = await read(activeCreditCardsProvider.future);
  final cardId = request.cardId ?? (cards.isEmpty ? null : cards.first.id);
  final amount = double.tryParse(request.amountText.trim());
  if (cardId == null) {
    return const WidgetQuickAddSaveFailure('Select a card');
  }
  if (amount == null || amount <= 0) {
    return const WidgetQuickAddSaveFailure('Enter a valid amount');
  }

  final creditCards = read(creditCardRepositoryProvider);
  final transactionAt = DateTime.now();
  final billingCycleId = await creditCards.findBillingCycleIdForTransaction(
    cardId: cardId,
    transactionAt: transactionAt,
  );
  final kind = request.kind == 'refund' ? 'refund' : 'expense';

  await read(cardTransactionRepositoryProvider).insert(
        NewCardTransaction(
          creditCardId: cardId,
          billingCycleId: billingCycleId,
          kind: kind,
          amountPaise: (amount * 100).round(),
          merchant: request.merchantText.trim().isEmpty
              ? (kind == 'refund' ? 'Refund' : 'Expense')
              : request.merchantText.trim(),
          transactionAt: transactionAt,
          source: 'Manual',
        ),
      );

  final ref = widgetRef;
  if (ref != null) {
    try {
      invalidateDashboardAndWidgets(ref);
    } catch (_) {
      // Widget sync may be unavailable outside the full app host.
    }
  }

  return const WidgetQuickAddSaveSuccess();
}
