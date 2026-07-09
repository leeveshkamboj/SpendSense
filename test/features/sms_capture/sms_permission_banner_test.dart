import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/presentation/sms_permission_banner.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';

void main() {
  group('SMS permission banner', () {
    testWidgets('shows banner when SMS permission is denied', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            smsPermissionStateProvider.overrideWith(
              (ref) async => SmsPermissionState.denied,
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: SmsPermissionBanner())),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('SMS permission is required'),
        findsOneWidget,
      );
      expect(find.text('Allow'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('hides banner when SMS permission is granted', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            smsPermissionStateProvider.overrideWith(
              (ref) async => SmsPermissionState.granted,
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: SmsPermissionBanner())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialBanner), findsNothing);
    });
  });
}
