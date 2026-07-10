import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/bills/notification_permission_gateway.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';
import 'package:spendsense/features/location/location_providers.dart';
import 'package:spendsense/features/onboarding/presentation/permissions_setup_screen.dart';
import 'package:spendsense/features/settings/data/app_preferences_repository.dart';
import 'package:spendsense/features/sms_capture/sms_permission_gateway.dart';
import 'package:spendsense/features/sms_capture/sms_permission_providers.dart';

void main() {
  testWidgets('permissions setup screen shows all permission tiles', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(() => database.close());
    await tester.binding.setSurfaceSize(const Size(800, 1200));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          smsPermissionGatewayProvider.overrideWithValue(
            InMemorySmsPermissionGateway(SmsPermissionState.denied),
          ),
          notificationPermissionGatewayProvider.overrideWithValue(
            InMemoryNotificationPermissionGateway(
              NotificationPermissionState.denied,
            ),
          ),
          locationPermissionGatewayProvider.overrideWithValue(
            InMemoryLocationPermissionGateway(LocationPermissionState.denied),
          ),
        ],
        child: MaterialApp(
          home: PermissionsSetupScreen(onComplete: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SMS'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Allow all'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });

  testWidgets('skip for now completes setup and marks location explained', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(() => database.close());
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    final preferences = AppPreferencesRepository(database);
    var completed = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          smsPermissionGatewayProvider.overrideWithValue(
            InMemorySmsPermissionGateway(SmsPermissionState.denied),
          ),
          notificationPermissionGatewayProvider.overrideWithValue(
            InMemoryNotificationPermissionGateway(
              NotificationPermissionState.denied,
            ),
          ),
          locationPermissionGatewayProvider.overrideWithValue(
            InMemoryLocationPermissionGateway(LocationPermissionState.denied),
          ),
        ],
        child: MaterialApp(
          home: PermissionsSetupScreen(
            onComplete: () => completed = true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip for now'));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(await preferences.locationPermissionExplained(), isTrue);
  });

  testWidgets('allow all requests each permission', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(() => database.close());
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    final smsGateway = InMemorySmsPermissionGateway(SmsPermissionState.denied);
    final notificationGateway = InMemoryNotificationPermissionGateway(
      NotificationPermissionState.denied,
    );
    final locationGateway =
        InMemoryLocationPermissionGateway(LocationPermissionState.denied);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          smsPermissionGatewayProvider.overrideWithValue(smsGateway),
          notificationPermissionGatewayProvider.overrideWithValue(
            notificationGateway,
          ),
          locationPermissionGatewayProvider.overrideWithValue(locationGateway),
        ],
        child: MaterialApp(
          home: PermissionsSetupScreen(onComplete: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Allow all'));
    await tester.pumpAndSettle();

    expect(await smsGateway.check(), SmsPermissionState.granted);
    expect(
      await notificationGateway.check(),
      NotificationPermissionState.granted,
    );
    expect(
      await locationGateway.check(),
      LocationPermissionState.granted,
    );
  });
}
