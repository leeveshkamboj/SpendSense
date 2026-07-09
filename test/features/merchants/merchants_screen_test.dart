import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/merchants/domain/merchant_list_item.dart';
import 'package:spendsense/features/merchants/presentation/merchant_list_providers.dart';
import 'package:spendsense/features/merchants/presentation/merchants_screen.dart';

void main() {
  group('Merchants screen', () {
    testWidgets('shows merchant with category and tags', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            merchantsListProvider.overrideWith(
              (ref) async => const [
                MerchantListItem(
                  rawName: 'ZOMATO LTD',
                  defaultCategory: 'Food',
                  tags: ['Personal'],
                ),
              ],
            ),
          ],
          child: const MaterialApp(home: MerchantsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ZOMATO LTD'), findsOneWidget);
      expect(find.text('Food · Personal'), findsOneWidget);
    });
  });
}
