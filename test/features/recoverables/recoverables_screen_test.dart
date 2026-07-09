import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';
import 'package:spendsense/features/recoverables/presentation/recoverables_screen.dart';

void main() {
  group('Recoverables screen', () {
    testWidgets('shows outstanding amounts grouped by person', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            recoverableSummaryProvider.overrideWith(
              (ref) async => {'Rahul': 5000, 'Priya': 8000},
            ),
          ],
          child: const MaterialApp(home: RecoverablesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rahul'), findsOneWidget);
      expect(find.text('₹50'), findsOneWidget);
      expect(find.text('Priya'), findsOneWidget);
      expect(find.text('₹80'), findsOneWidget);
    });
  });
}
