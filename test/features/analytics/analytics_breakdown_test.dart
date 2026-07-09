import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/analytics/domain/analytics_transaction.dart';
import 'package:spendsense/features/analytics/engine/analytics_breakdown.dart';
import 'package:spendsense/features/budgets/domain/budget_transaction.dart';

void main() {
  group('Analytics breakdown', () {
    test('category and merchant totals exclude recoverables', () {
      const transactions = [
        AnalyticsTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: false,
          amountPaise: 50000,
          merchant: 'ZOMATO LTD',
          category: 'Food',
        ),
        AnalyticsTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: true,
          amountPaise: 30000,
          merchant: 'SWIGGY',
          category: 'Food',
        ),
      ];

      final categories = calculateCategoryAnalytics(transactions);
      final merchants = calculateMerchantAnalytics(transactions);

      expect(categories['Food'], 50000);
      expect(merchants['ZOMATO LTD'], 50000);
      expect(merchants.containsKey('SWIGGY'), isFalse);
    });

    test('card and tag totals include recoverables', () {
      const transactions = [
        AnalyticsTransaction(
          source: BudgetTransactionSource.creditCard,
          kind: BudgetTransactionKind.expense,
          isRecoverable: true,
          amountPaise: 30000,
          merchant: 'SWIGGY',
          cardNickname: 'SBI ••1234',
          tags: ['Dining'],
        ),
      ];

      final cards = calculateCardAnalytics(transactions);
      final tags = calculateTagAnalytics(transactions);

      expect(cards['SBI ••1234'], 30000);
      expect(tags['Dining'], 30000);
    });
  });
}
