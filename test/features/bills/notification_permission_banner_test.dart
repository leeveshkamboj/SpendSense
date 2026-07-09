import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';

void main() {
  group('Notification permission banner', () {
    testWidgets('shows banner when notification permission is denied', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationPermissionStateProvider.overrideWith(
              (ref) async => NotificationPermissionState.denied,
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: NotificationPermissionBanner())),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Bill reminders require notification permission'),
        findsOneWidget,
      );
      expect(find.text('Allow'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('hides banner when notification permission is granted', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationPermissionStateProvider.overrideWith(
              (ref) async => NotificationPermissionState.granted,
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: NotificationPermissionBanner())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MaterialBanner), findsNothing);
    });
  });
}
