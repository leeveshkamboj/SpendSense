import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_sms.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/domain/captured_transaction_snapshot.dart';
import 'package:spendsense/features/sms_capture/duplicate_detection.dart';
import 'package:spendsense/features/sms_capture/parsers/sms_parser.dart';
import 'package:spendsense/features/sms_capture/unparsed_sms_notifier.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

typedef CaptureNotificationHandler = void Function(CaptureNotificationEvent);
typedef ManualAddNotificationHandler = void Function(String sms);

class SmsCaptureService {
  SmsCaptureService({
    required CreditCardRepository creditCards,
    required CardTransactionRepository cardTransactions,
    required BankAccountRepository bankAccounts,
    required BankAccountTransactionRepository bankAccountTransactions,
    this.onCaptured,
    this.onManualAddSuggested,
  })  : _creditCards = creditCards,
        _cardTransactions = cardTransactions,
        _bankAccounts = bankAccounts,
        _bankAccountTransactions = bankAccountTransactions;

  final CreditCardRepository _creditCards;
  final CardTransactionRepository _cardTransactions;
  final BankAccountRepository _bankAccounts;
  final BankAccountTransactionRepository _bankAccountTransactions;
  final CaptureNotificationHandler? onCaptured;
  final ManualAddNotificationHandler? onManualAddSuggested;

  Future<SmsCaptureResult> processSms(String sms) async {
    final parsed = parseBankSms(sms);
    if (parsed == null) {
      if (shouldNotifyManualAdd(sms)) {
        onManualAddSuggested?.call(sms);
      }
      return SmsCaptureResult.ignored;
    }

    return switch (parsed) {
      ParsedCardExpenseMessage(:final expense) => _captureCardExpense(expense),
      ParsedBankTransactionMessage(:final transaction) =>
        _captureBankTransaction(transaction),
    };
  }

  Future<SmsCaptureResult> _captureCardExpense(ParsedCardExpense parsed) async {
    final cardId = await _resolveCardId(parsed);
    if (await _isCardDuplicate(parsed, cardId)) {
      return SmsCaptureResult.duplicate;
    }

    final billingCycleId = await _creditCards.findBillingCycleIdForTransaction(
      cardId: cardId,
      transactionAt: parsed.transactionAt,
    );

    final transactionId = await _cardTransactions.insert(
      NewCardTransaction(
        creditCardId: cardId,
        billingCycleId: billingCycleId,
        kind: 'expense',
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        transactionAt: parsed.transactionAt,
        source: 'SMS',
        rawSms: parsed.rawSms,
        referenceNumber: parsed.referenceNumber,
      ),
    );

    final card = await _creditCards.getById(cardId);
    onCaptured?.call(
      CaptureNotificationEvent(
        transactionId: transactionId,
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        cardNickname: card?.nickname ?? parsed.bank,
        isBankAccount: false,
      ),
    );

    return SmsCaptureResult.captured;
  }

  Future<SmsCaptureResult> _captureBankTransaction(
    ParsedBankTransaction parsed,
  ) async {
    final accountId = await _resolveBankAccountId(parsed);
    if (await _isBankDuplicate(parsed, accountId)) {
      return SmsCaptureResult.duplicate;
    }

    final kind = parsed.kind == BankTransactionKind.debit ? 'debit' : 'credit';
    final transactionId = await _bankAccountTransactions.insert(
      NewBankAccountTransaction(
        bankAccountId: accountId,
        kind: kind,
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        beneficiary: parsed.beneficiary,
        category: parsed.category,
        transactionAt: parsed.transactionAt,
        source: 'SMS',
        rawSms: parsed.rawSms,
        referenceNumber: parsed.referenceNumber,
      ),
    );

    final account = await _bankAccounts.getById(accountId);
    onCaptured?.call(
      CaptureNotificationEvent(
        transactionId: transactionId,
        amountPaise: parsed.amountPaise,
        merchant: parsed.beneficiary ?? parsed.merchant ?? parsed.bank,
        cardNickname: account?.nickname ?? parsed.bank,
        isBankAccount: true,
      ),
    );

    return SmsCaptureResult.captured;
  }

  Future<int> _resolveCardId(ParsedCardExpense parsed) async {
    final existing = await _creditCards.findByBankAndLastFour(
      bank: parsed.bank,
      lastFourDigits: parsed.lastFourDigits,
    );
    if (existing != null) return existing.id;

    return _creditCards.autoCreateFromSms(
      bank: parsed.bank,
      lastFourDigits: parsed.lastFourDigits,
    );
  }

  Future<int> _resolveBankAccountId(ParsedBankTransaction parsed) async {
    final existing = await _bankAccounts.findByBankAndLastFour(
      bank: parsed.bank,
      lastFourDigits: parsed.lastFourDigits,
    );
    if (existing != null) return existing.id;

    return _bankAccounts.autoCreateFromSms(
      bank: parsed.bank,
      lastFourDigits: parsed.lastFourDigits,
    );
  }

  Future<bool> _isCardDuplicate(ParsedCardExpense parsed, int cardId) async {
    final existing = await _cardTransactions.listSnapshotsForCard(cardId);
    return matchesExistingCapture(
      incoming: CapturedTransactionSnapshot(
        creditCardId: cardId,
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        transactionAt: parsed.transactionAt,
        referenceNumber: parsed.referenceNumber,
      ),
      existing: existing,
    );
  }

  Future<bool> _isBankDuplicate(
    ParsedBankTransaction parsed,
    int accountId,
  ) async {
    final existing =
        await _bankAccountTransactions.listSnapshotsForAccount(accountId);
    return matchesExistingCapture(
      incoming: CapturedTransactionSnapshot(
        bankAccountId: accountId,
        amountPaise: parsed.amountPaise,
        merchant: parsed.beneficiary ?? parsed.merchant ?? 'Unknown',
        transactionAt: parsed.transactionAt,
        referenceNumber: parsed.referenceNumber,
      ),
      existing: existing,
    );
  }
}
