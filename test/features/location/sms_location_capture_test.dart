import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:spendsense/features/location/data/geolocation_service.dart';
import 'package:spendsense/features/location/data/sms_location_capture.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';

class _FakePermissionGateway implements LocationPermissionGateway {
  _FakePermissionGateway(this._state);

  LocationPermissionState _state;

  @override
  Future<LocationPermissionState> check() async => _state;

  @override
  Future<LocationPermissionState> request() async => _state;

  void setState(LocationPermissionState state) => _state = state;
}

class _FakeGeolocationService extends GeolocationService {
  _FakeGeolocationService({
    required super.permissionGateway,
    this.position,
    this.label,
  });

  LatLng? position;
  String? label;

  @override
  Future<LatLng?> readCurrentPositionIfPermitted() async => position;

  @override
  Future<String?> reverseGeocode(LatLng coordinates) async => label;
}

void main() {
  group('SmsLocationCapture', () {
    late _FakePermissionGateway permissionGateway;
    late _FakeGeolocationService geolocation;
    late SmsLocationCapture capture;

    setUp(() {
      permissionGateway = _FakePermissionGateway(
        LocationPermissionState.denied,
      );
      geolocation = _FakeGeolocationService(
        permissionGateway: permissionGateway,
        position: const LatLng(12.9716, 77.5946),
        label: 'Bengaluru',
      );
      capture = SmsLocationCapture(
        permissionGateway: permissionGateway,
        geolocation: geolocation,
      );
    });

    test('returns null when permission is not granted', () async {
      expect(await capture.captureSerialized(), isNull);
    });

    test('serializes coordinates and label when permission is granted', () async {
      permissionGateway.setState(LocationPermissionState.granted);

      final serialized = await capture.captureSerialized();
      expect(serialized, isNotNull);
      expect(serialized, endsWith('|Bengaluru'));
      expect(serialized, startsWith('geo:12.9716'));
      expect(serialized, contains(',77.5946'));
    });

    test('returns null when coordinates are unavailable', () async {
      permissionGateway.setState(LocationPermissionState.granted);
      geolocation.position = null;

      expect(await capture.captureSerialized(), isNull);
    });
  });
}
