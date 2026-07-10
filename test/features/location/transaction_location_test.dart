import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/location/domain/transaction_location.dart';

void main() {
  group('TransactionLocation', () {
    test('parses geo coordinates with label', () {
      final location = TransactionLocation.parse(
        'geo:12.971600,77.594600|Indiranagar, Bangalore',
      );

      expect(location?.latitude, 12.9716);
      expect(location?.longitude, 77.5946);
      expect(location?.label, 'Indiranagar, Bangalore');
      expect(location?.hasCoordinates, isTrue);
    });

    test('parses legacy plain text as label only', () {
      final location = TransactionLocation.parse('Bangalore');

      expect(location?.hasCoordinates, isFalse);
      expect(location?.label, 'Bangalore');
      expect(location?.displayLabel(), 'Bangalore');
    });

    test('serializes coordinates and label', () {
      const location = TransactionLocation(
        latitude: 12.9716,
        longitude: 77.5946,
        label: 'Cafe',
      );

      expect(
        location.serialize(),
        'geo:12.971600,77.594600|Cafe',
      );
    });

    test('round-trips through storage format', () {
      const original = TransactionLocation(
        latitude: 19.076,
        longitude: 72.8777,
        label: 'Mumbai',
      );

      final parsed = TransactionLocation.parse(original.serialize());
      expect(parsed?.latitude, original.latitude);
      expect(parsed?.longitude, original.longitude);
      expect(parsed?.label, original.label);
    });
  });
}
