import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/onboarding/presentation/onboarding_flow.dart';
import 'package:spendsense/features/onboarding/presentation/welcome_screen.dart';

void main() {
  group('Onboarding restore', () {
    testWidgets('welcome screen opens restore flow', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: OnboardingFlow()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tester.tap(find.text('Restore from backup'));
      await tester.pumpAndSettle();

      expect(find.text('Choose backup file'), findsOneWidget);
    });
  });
}
