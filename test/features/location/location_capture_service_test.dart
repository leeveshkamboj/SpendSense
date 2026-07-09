import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';

void main() {
  group('LocationCaptureService', () {
    test('shows explanation on first denial', () async {
      final gateway = InMemoryLocationPermissionGateway(
        LocationPermissionState.denied,
      );
      var explained = false;

      final service = LocationCaptureService(
        permissionGateway: gateway,
        locationExplained: () async => explained,
        markLocationExplained: () async => explained = true,
      );

      final decision = await service.requestForCapture();

      expect(decision, LocationCaptureDecision.showExplanation);
    });

    test('skips silently after explanation was shown', () async {
      final gateway = InMemoryLocationPermissionGateway(
        LocationPermissionState.denied,
      );

      final service = LocationCaptureService(
        permissionGateway: gateway,
        locationExplained: () async => true,
        markLocationExplained: () async {},
      );

      final decision = await service.requestForCapture();

      expect(decision, LocationCaptureDecision.skipSilently);
    });
  });
}
