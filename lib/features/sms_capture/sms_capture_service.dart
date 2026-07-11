import 'package:spendsense/features/accounts/data/bank_account_repository.dart';
import 'package:spendsense/features/accounts/data/bank_account_transaction_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/sms_capture/data/seen_sms_repository.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_bank_transaction.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_expense.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_sms.dart';
import 'package:spendsense/features/sms_capture/domain/sms_capture_result.dart';
import 'package:spendsense/features/sms_capture/domain/captured_transaction_snapshot.dart';
import 'package:spendsense/features/sms_capture/duplicate_detection.dart';
import 'package:spendsense/features/sms_capture/parsers/sms_parser.dart';
import 'package:spendsense/features/sms_capture/sms_debug_log.dart';
import 'package:spendsense/features/sms_capture/unparsed_sms_notifier.dart';
import 'package:spendsense/features/linking/data/linking_repository.dart';
import 'package:spendsense/features/merchants/data/merchant_repository.dart';
import 'package:spendsense/features/sms_capture/domain/parsed_card_credit.dart';
import 'package:spendsense/features/tags/data/tag_repository.dart';
import 'package:spendsense/features/transactions/data/card_transaction_repository.dart';

typedef CaptureNotificationHandler = void Function(CaptureNotificationEvent);
typedef ManualAddNotificationHandler = void Function(String sms);
typedef SmsLocationResolver = Future<String?> Function();

class SmsCaptureService {
  SmsCaptureService({
    required CreditCardRepository creditCards,
    required CardTransactionRepository cardTransactions,
    required BankAccountRepository bankAccounts,
    required BankAccountTransactionRepository bankAccountTransactions,
    required MerchantRepository merchants,
    required TagRepository tags,
    required LinkingRepository linking,
    required SeenSmsRepository seenSms,
    this.onCaptured,
    this.onManualAddSuggested,
    SmsLocationResolver? resolveLocation,
  })  : _creditCards = creditCards,
        _cardTransactions = cardTransactions,
        _bankAccounts = bankAccounts,
        _bankAccountTransactions = bankAccountTransactions,
        _merchants = merchants,
        _tags = tags,
        _linking = linking,
        _seenSms = seenSms,
        _resolveLocation = resolveLocation;

  final CreditCardRepository _creditCards;
  final CardTransactionRepository _cardTransactions;
  final BankAccountRepository _bankAccounts;
  final BankAccountTransactionRepository _bankAccountTransactions;
  final MerchantRepository _merchants;
  final TagRepository _tags;
  final LinkingRepository _linking;
  final SeenSmsRepository _seenSms;
  final CaptureNotificationHandler? onCaptured;
  final ManualAddNotificationHandler? onManualAddSuggested;
  final SmsLocationResolver? _resolveLocation;

  Future<SmsCaptureResult> processSms(
    String sms, {
    bool notifyUnparsed = true,
  }) async {
    if (await _seenSms.contains(sms)) {
      smsDebugLog('processSms duplicate (seen body)');
      return SmsCaptureResult.duplicate;
    }

    final parsed = parseBankSms(sms);
    if (parsed == null) {
      final preview = sms.length > 100 ? '${sms.substring(0, 100)}…' : sms;
      smsDebugLog('processSms ignored (unparsed) body="$preview"');
      if (notifyUnparsed && shouldNotifyManualAdd(sms)) {
        onManualAddSuggested?.call(sms);
      }
      return SmsCaptureResult.ignored;
    }

    smsDebugLog('processSms parsed=${parsed.runtimeType}');
    final location = await _captureLocation();

    final result = await switch (parsed) {
      ParsedCardExpenseMessage(:final expense) =>
        _captureCardExpense(expense, location),
      ParsedCardCreditMessage(:final credit) => _captureCardCredit(
          credit,
          location: location,
        ),
      ParsedBankTransactionMessage(:final transaction) =>
        _captureBankTransaction(transaction, location),
    };
    if (result == SmsCaptureResult.captured ||
        result == SmsCaptureResult.duplicate) {
      await _seenSms.remember(sms);
    }
    smsDebugLog('processSms result=${result.name}');
    return result;
  }

  Future<String?> _captureLocation() async {
    final resolver = _resolveLocation;
    if (resolver == null) {
      return null;
    }

    try {
      return await resolver();
    } catch (_) {
      return null;
    }
  }

  Future<SmsCaptureResult> _captureCardExpense(
    ParsedCardExpense parsed,
    String? location,
  ) async {
    final cardId = await _resolveCardId(parsed);
    if (await _isCardDuplicate(parsed, cardId)) {
      return SmsCaptureResult.duplicate;
    }

    final billingCycleId = await _creditCards.findBillingCycleIdForTransaction(
      cardId: cardId,
      transactionAt: parsed.transactionAt,
    );

    final category = await _merchants.resolveDefaultCategory(parsed.merchant);

    final transactionId = await _cardTransactions.insert(
      NewCardTransaction(
        creditCardId: cardId,
        billingCycleId: billingCycleId,
        kind: 'expense',
        amountPaise: parsed.amountPaise,
        merchant: parsed.merchant,
        category: category,
        transactionAt: parsed.transactionAt,
        source: 'SMS',
        rawSms: parsed.rawSms,
        referenceNumber: parsed.referenceNumber,
        location: location,
      ),
    );

    final defaultTags = await _merchants.resolveDefaultTags(parsed.merchant);
    if (defaultTags.isNotEmpty) {
      await _tags.setForCardTransaction(
        transactionId: transactionId,
        tagNames: defaultTags,
      );
    }

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
    String? location,
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
        location: location,
      ),
    );

    await _linking.tryLinkBankTransaction(
      transactionId: transactionId,
      accountId: accountId,
      kind: kind,
      amountPaise: parsed.amountPaise,
      transactionAt: parsed.transactionAt,
      isCardPayment: parsed.isCardPayment,
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

  Future<SmsCaptureResult> _captureCardCredit(
    ParsedCardCredit parsed, {
    String? location,
  }) async {
    final cardId = await _resolveCardIdFromCredit(parsed);
    if (await _isCardCreditDuplicate(parsed, cardId)) {
      return SmsCaptureResult.duplicate;
    }

    return switch (parsed.kind) {
      ParsedCardCreditKind.refund => _captureRefund(
          parsed,
          cardId,
          location: location,
        ),
      ParsedCardCreditKind.cardPayment => _captureCardPayment(
          parsed,
          cardId,
          location: location,
        ),
    };
  }

  Future<SmsCaptureResult> _captureRefund(
    ParsedCardCredit parsed,
    int cardId, {
    String? location,
  }) async {
    final merchant = parsed.merchant ?? 'Refund';
    final billingCycleId = await _linking.resolveRefundBillingCycleId(
      cardId: cardId,
      merchant: merchant,
      amountPaise: parsed.amountPaise,
    );

    final transactionId = await _cardTransactions.insert(
      NewCardTransaction(
        creditCardId: cardId,
        billingCycleId: billingCycleId,
        kind: 'refund',
        amountPaise: parsed.amountPaise,
        merchant: merchant,
        transactionAt: parsed.transactionAt,
        source: 'SMS',
        rawSms: parsed.rawSms,
        referenceNumber: parsed.referenceNumber,
        location: location,
      ),
    );

    final originalId = await _linking.findRefundOriginalExpenseId(
      cardId: cardId,
      merchant: merchant,
      amountPaise: parsed.amountPaise,
    );
    if (originalId != null) {
      await _linking.recordRefundLink(
        refundTransactionId: transactionId,
        originalExpenseTransactionId: originalId,
      );
    }

    final card = await _creditCards.getById(cardId);
    onCaptured?.call(
      CaptureNotificationEvent(
        transactionId: transactionId,
        amountPaise: parsed.amountPaise,
        merchant: merchant,
        cardNickname: card?.nickname ?? parsed.bank,
        isBankAccount: false,
      ),
    );

    return SmsCaptureResult.captured;
  }

  Future<SmsCaptureResult> _captureCardPayment(
    ParsedCardCredit parsed,
    int cardId, {
    String? location,
  }) async {
    final transactionId = await _cardTransactions.insert(
      NewCardTransaction(
        creditCardId: cardId,
        kind: 'card_payment',
        amountPaise: parsed.amountPaise,
        merchant: 'Card Payment',
        transactionAt: parsed.transactionAt,
        source: 'SMS',
        rawSms: parsed.rawSms,
        referenceNumber: parsed.referenceNumber,
        location: location,
      ),
    );

    await _linking.applyCardPayment(
      cardId: cardId,
      cardPaymentTransactionId: transactionId,
      paymentAmountPaise: parsed.amountPaise,
      asOf: parsed.transactionAt,
    );
    await _linking.tryLinkCardPayment(
      cardPaymentTransactionId: transactionId,
      amountPaise: parsed.amountPaise,
      transactionAt: parsed.transactionAt,
    );

    final card = await _creditCards.getById(cardId);
    onCaptured?.call(
      CaptureNotificationEvent(
        transactionId: transactionId,
        amountPaise: parsed.amountPaise,
        merchant: 'Card Payment',
        cardNickname: card?.nickname ?? parsed.bank,
        isBankAccount: false,
      ),
    );

    return SmsCaptureResult.captured;
  }

  Future<int> _resolveCardIdFromCredit(ParsedCardCredit parsed) async {
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

  Future<bool> _isCardCreditDuplicate(ParsedCardCredit parsed, int cardId) async {
    final existing = await _cardTransactions.listSnapshotsForCard(cardId);
    final merchant = parsed.merchant ?? 'Card Payment';
    return matchesExistingCapture(
      incoming: CapturedTransactionSnapshot(
        creditCardId: cardId,
        amountPaise: parsed.amountPaise,
        merchant: merchant,
        transactionAt: parsed.transactionAt,
        referenceNumber: parsed.referenceNumber,
      ),
      existing: existing,
    );
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
    final incoming = CapturedTransactionSnapshot(
      creditCardId: cardId,
      amountPaise: parsed.amountPaise,
      merchant: parsed.merchant,
      transactionAt: parsed.transactionAt,
      referenceNumber: parsed.referenceNumber,
    );
    final reason = duplicateMatchReason(incoming: incoming, existing: existing);
    if (reason != null) {
      smsDebugLog(
        'duplicate card expense amountPaise=${parsed.amountPaise} '
        'merchant=${parsed.merchant} reason=$reason',
      );
      return true;
    }
    return false;
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
