import 'package:spendsense/features/location/data/geolocation_service.dart';
import 'package:spendsense/features/location/domain/transaction_location.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';

class SmsLocationCapture {
  SmsLocationCapture({
    required LocationPermissionGateway permissionGateway,
    required GeolocationService geolocation,
  })  : _permissionGateway = permissionGateway,
        _geolocation = geolocation;

  final LocationPermissionGateway _permissionGateway;
  final GeolocationService _geolocation;

  Future<String?> captureSerialized() async {
    if (await _permissionGateway.check() != LocationPermissionState.granted) {
      return null;
    }

    final coordinates = await _geolocation.readCurrentPositionIfPermitted();
    if (coordinates == null) {
      return null;
    }

    final label = await _geolocation.reverseGeocode(coordinates);
    return TransactionLocation(
      latitude: coordinates.latitude,
      longitude: coordinates.longitude,
      label: label,
    ).serialize();
  }
}
