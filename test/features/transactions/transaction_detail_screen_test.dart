import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';

void main() {
  testWidgets('shows original SMS on transaction detail', (tester) async {
    const rawSms =
        'Spent Rs.411.67 On HDFC Bank Card 5534 At ZOMATO LTD On 2026-07-09:16:15:20.';
    final database = AppDatabase(NativeDatabase.memory());

    final transactionId = await database.into(database.cardTransactions).insert(
          CardTransactionsCompanion.insert(
            creditCardId: 1,
            kind: 'expense',
            amountPaise: 41167,
            merchant: 'ZOMATO LTD',
            transactionAt: DateTime(2026, 7, 9, 16, 15, 20),
            source: 'SMS',
            rawSms: const Value(rawSms),
            createdAt: DateTime.now(),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: MaterialApp(
          home: TransactionDetailScreen(transactionId: transactionId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Original SMS'), findsOneWidget);
    expect(find.text(rawSms), findsOneWidget);

    await database.close();
  });
}
