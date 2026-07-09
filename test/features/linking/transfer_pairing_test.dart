import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/linking/domain/transfer_candidate.dart';
import 'package:spendsense/features/linking/engine/transfer_pairing.dart';

void main() {
  group('Transfer pairing', () {
    final at = DateTime(2026, 7, 9, 10);

    test('pairs debit with credit on different account with same amount', () {
      final match = findTransferPair(
        incoming: TransferCandidate(
          transactionId: 1,
          accountId: 10,
          kind: TransferSideKind.debit,
          amountPaise: 500000,
          transactionAt: at,
        ),
        candidates: [
          TransferCandidate(
            transactionId: 2,
            accountId: 20,
            kind: TransferSideKind.credit,
            amountPaise: 500000,
            transactionAt: at.add(const Duration(minutes: 2)),
          ),
        ],
      );

      expect(match?.pairedTransactionId, 2);
    });

    test('ignores same-account candidates', () {
      final match = findTransferPair(
        incoming: TransferCandidate(
          transactionId: 1,
          accountId: 10,
          kind: TransferSideKind.debit,
          amountPaise: 500000,
          transactionAt: at,
        ),
        candidates: [
          TransferCandidate(
            transactionId: 2,
            accountId: 10,
            kind: TransferSideKind.credit,
            amountPaise: 500000,
            transactionAt: at,
          ),
        ],
      );

      expect(match, isNull);
    });

    test('ignores candidates outside five-minute window', () {
      final match = findTransferPair(
        incoming: TransferCandidate(
          transactionId: 1,
          accountId: 10,
          kind: TransferSideKind.debit,
          amountPaise: 500000,
          transactionAt: at,
        ),
        candidates: [
          TransferCandidate(
            transactionId: 2,
            accountId: 20,
            kind: TransferSideKind.credit,
            amountPaise: 500000,
            transactionAt: at.add(const Duration(minutes: 6)),
          ),
        ],
      );

      expect(match, isNull);
    });
  });
}
