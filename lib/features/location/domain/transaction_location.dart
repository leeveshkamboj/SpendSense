import 'package:latlong2/latlong.dart';

class TransactionLocation {
  const TransactionLocation({
    this.latitude,
    this.longitude,
    this.label,
  });

  final double? latitude;
  final double? longitude;
  final String? label;

  bool get hasCoordinates => latitude != null && longitude != null;

  LatLng? get coordinates {
    if (!hasCoordinates) {
      return null;
    }
    return LatLng(latitude!, longitude!);
  }

  static TransactionLocation? parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final trimmed = raw.trim();
    if (!trimmed.startsWith('geo:')) {
      return TransactionLocation(label: trimmed);
    }

    final payload = trimmed.substring(4);
    final separatorIndex = payload.indexOf('|');
    final coordinatePart =
        separatorIndex == -1 ? payload : payload.substring(0, separatorIndex);
    final labelPart =
        separatorIndex == -1 ? null : payload.substring(separatorIndex + 1);

    final parts = coordinatePart.split(',');
    if (parts.length != 2) {
      return TransactionLocation(label: trimmed);
    }

    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());
    if (latitude == null || longitude == null) {
      return TransactionLocation(label: trimmed);
    }

    final label = labelPart?.trim();
    return TransactionLocation(
      latitude: latitude,
      longitude: longitude,
      label: label?.isEmpty ?? true ? null : label,
    );
  }

  String? serialize() {
    if (hasCoordinates) {
      final coordinates =
          'geo:${latitude!.toStringAsFixed(6)},${longitude!.toStringAsFixed(6)}';
      final text = label?.trim();
      if (text != null && text.isNotEmpty) {
        return '$coordinates|$text';
      }
      return coordinates;
    }

    final text = label?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  String displayLabel() {
    final text = label?.trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
    if (hasCoordinates) {
      return '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';
    }
    return 'No location set';
  }

  TransactionLocation copyWith({
    double? latitude,
    double? longitude,
    String? label,
    bool clearLabel = false,
  }) {
    return TransactionLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: clearLabel ? null : (label ?? this.label),
    );
  }
}
