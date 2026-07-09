import 'package:permission_handler/permission_handler.dart';

enum LocationPermissionState {
  granted,
  denied,
  permanentlyDenied,
}

abstract class LocationPermissionGateway {
  Future<LocationPermissionState> check();
  Future<LocationPermissionState> request();
}

class PlatformLocationPermissionGateway implements LocationPermissionGateway {
  @override
  Future<LocationPermissionState> check() async {
    return _map(await Permission.locationWhenInUse.status);
  }

  @override
  Future<LocationPermissionState> request() async {
    return _map(await Permission.locationWhenInUse.request());
  }

  LocationPermissionState _map(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited ||
      PermissionStatus.provisional =>
        LocationPermissionState.granted,
      PermissionStatus.permanentlyDenied =>
        LocationPermissionState.permanentlyDenied,
      _ => LocationPermissionState.denied,
    };
  }
}

class InMemoryLocationPermissionGateway implements LocationPermissionGateway {
  InMemoryLocationPermissionGateway(this._state);

  LocationPermissionState _state;

  @override
  Future<LocationPermissionState> check() async => _state;

  @override
  Future<LocationPermissionState> request() async => _state;

  void setState(LocationPermissionState state) => _state = state;
}

class LocationCaptureService {
  LocationCaptureService({
    required LocationPermissionGateway permissionGateway,
    required Future<bool> Function() locationExplained,
    required Future<void> Function() markLocationExplained,
  })  : _permissionGateway = permissionGateway,
        _locationExplained = locationExplained,
        _markLocationExplained = markLocationExplained;

  final LocationPermissionGateway _permissionGateway;
  final Future<bool> Function() _locationExplained;
  final Future<void> Function() _markLocationExplained;

  Future<LocationCaptureDecision> requestForCapture() async {
    final current = await _permissionGateway.check();
    if (current == LocationPermissionState.granted) {
      return LocationCaptureDecision.capture;
    }

    final explained = await _locationExplained();
    if (!explained) {
      return LocationCaptureDecision.showExplanation;
    }

    return LocationCaptureDecision.skipSilently;
  }

  Future<LocationCaptureDecision> completeExplanationFlow() async {
    await _markLocationExplained();
    final result = await _permissionGateway.request();
    if (result == LocationPermissionState.granted) {
      return LocationCaptureDecision.capture;
    }
    return LocationCaptureDecision.skipSilently;
  }
}

enum LocationCaptureDecision {
  capture,
  showExplanation,
  skipSilently,
}
