import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:spendsense/features/location/location_permission_gateway.dart';

class GeolocationService {
  GeolocationService({
    required LocationPermissionGateway permissionGateway,
  }) : _permissionGateway = permissionGateway;

  final LocationPermissionGateway _permissionGateway;

  Future<LatLng?> readCurrentPosition() async {
    if (!await _ensurePermission()) {
      return null;
    }

    return readCurrentPositionIfPermitted();
  }

  Future<LatLng?> readCurrentPositionIfPermitted() async {
    if (await _permissionGateway.check() != LocationPermissionState.granted) {
      return null;
    }

    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) {
      final age = DateTime.now().difference(lastKnown.timestamp);
      if (age <= const Duration(minutes: 15)) {
        return LatLng(lastKnown.latitude, lastKnown.longitude);
      }
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      if (lastKnown == null) {
        return null;
      }
      return LatLng(lastKnown.latitude, lastKnown.longitude);
    }
  }

  Future<String?> reverseGeocode(LatLng coordinates) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      if (placemarks.isEmpty) {
        return null;
      }

      final place = placemarks.first;
      final parts = <String>[
        if (place.name != null && place.name!.trim().isNotEmpty) place.name!.trim(),
        if (place.street != null && place.street!.trim().isNotEmpty)
          place.street!.trim(),
        if (place.locality != null && place.locality!.trim().isNotEmpty)
          place.locality!.trim(),
        if (place.administrativeArea != null &&
            place.administrativeArea!.trim().isNotEmpty)
          place.administrativeArea!.trim(),
      ];

      final uniqueParts = <String>[];
      for (final part in parts) {
        if (!uniqueParts.contains(part)) {
          uniqueParts.add(part);
        }
      }

      if (uniqueParts.isEmpty) {
        return null;
      }
      return uniqueParts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<bool> _ensurePermission() async {
    var permission = await _permissionGateway.check();
    if (permission == LocationPermissionState.granted) {
      return true;
    }

    permission = await _permissionGateway.request();
    return permission == LocationPermissionState.granted;
  }
}
