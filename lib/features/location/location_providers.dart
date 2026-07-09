import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';

final locationPermissionGatewayProvider = Provider<LocationPermissionGateway>((ref) {
  return PlatformLocationPermissionGateway();
});

final locationCaptureServiceProvider = Provider<LocationCaptureService>((ref) {
  final preferences = ref.watch(appPreferencesRepositoryProvider);
  return LocationCaptureService(
    permissionGateway: ref.watch(locationPermissionGatewayProvider),
    locationExplained: preferences.locationPermissionExplained,
    markLocationExplained: preferences.markLocationPermissionExplained,
  );
});
