import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/backup/domain/restore_verification_summary.dart';
import 'package:spendsense/features/backup/presentation/restore_verification_screen.dart';

void main() {
  group('Restore verification screen', () {
    testWidgets('shows restored card nicknames from backup', (tester) async {
      var continued = false;

      await tester.pumpWidget(
        MaterialApp(
          home: RestoreVerificationScreen(
            summary: RestoreVerificationSummary(
              backupDate: DateTime(2026, 7, 10),
              cardNicknames: const ['HDFC ••5534', 'SBI ••1234'],
            ),
            onContinue: () => continued = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('10/07/2026'), findsOneWidget);
      expect(find.text('HDFC ••5534'), findsOneWidget);
      expect(find.text('SBI ••1234'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(continued, isTrue);
    });
  });
}
