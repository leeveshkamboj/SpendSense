import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/sms_capture/domain/captured_transaction_snapshot.dart';
import 'package:spendsense/features/sms_capture/duplicate_detection.dart';

void main() {
  group('Duplicate detection', () {
    final incoming = CapturedTransactionSnapshot(
      creditCardId: 1,
      amountPaise: 41167,
      merchant: 'ZOMATO LTD',
      referenceNumber: 'UPI123',
      transactionAt: DateTime(2026, 7, 9, 16, 15, 20),
    );

    test('discards duplicate when reference number matches', () {
      final isDuplicate = matchesExistingCapture(
        incoming: incoming,
        existing: [
          CapturedTransactionSnapshot(
            creditCardId: 1,
            amountPaise: 41167,
            merchant: 'ZOMATO LTD',
            referenceNumber: 'UPI123',
            transactionAt: DateTime(2026, 7, 9, 16, 10),
          ),
        ],
      );

      expect(isDuplicate, isTrue);
    });

    test('discards duplicate with same amount and merchant within five minutes', () {
      final isDuplicate = matchesExistingCapture(
        incoming: CapturedTransactionSnapshot(
          creditCardId: 1,
          amountPaise: 41167,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9, 16, 15, 20),
        ),
        existing: [
          CapturedTransactionSnapshot(
            creditCardId: 1,
            amountPaise: 41167,
            merchant: 'ZOMATO LTD',
            transactionAt: DateTime(2026, 7, 9, 16, 17),
          ),
        ],
      );

      expect(isDuplicate, isTrue);
    });

    test('allows same amount and merchant outside five-minute window', () {
      final isDuplicate = matchesExistingCapture(
        incoming: CapturedTransactionSnapshot(
          creditCardId: 1,
          amountPaise: 41167,
          merchant: 'ZOMATO LTD',
          transactionAt: DateTime(2026, 7, 9, 16, 15, 20),
        ),
        existing: [
          CapturedTransactionSnapshot(
            creditCardId: 1,
            amountPaise: 41167,
            merchant: 'ZOMATO LTD',
            transactionAt: DateTime(2026, 7, 9, 16, 5),
          ),
        ],
      );

      expect(isDuplicate, isFalse);
    });
  });
}
