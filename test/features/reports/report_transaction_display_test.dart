import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/reports/engine/report_transaction_display.dart';

void main() {
  group('report transaction display', () {
    test('maps card kinds to debit, credit, or payment', () {
      expect(reportCardDirectionLabel('expense'), 'Debit');
      expect(reportCardDirectionLabel('refund'), 'Credit');
      expect(reportCardDirectionLabel('card_payment'), 'Payment');
    });

    test('maps bank kinds to debit or credit', () {
      expect(reportBankDirectionLabel('debit'), 'Debit');
      expect(reportBankDirectionLabel('credit'), 'Credit');
    });

    test('formats signed amounts for debit and credit', () {
      expect(reportSignedAmount(50000, 'Debit'), '-₹500');
      expect(reportSignedAmount(50000, 'Credit'), '+₹500');
      expect(reportSignedAmount(50000, 'Payment'), '₹500');
    });
  });
}
