final _transactionKeywordPattern = RegExp(
  r'\b(debited|debited by|credited|credited by|spent|txn|trxn|transaction|upi|neft|imps|payment)\b',
  caseSensitive: false,
);

bool hasTransactionKeywords(String sms) {
  return _transactionKeywordPattern.hasMatch(sms);
}

bool shouldNotifyManualAdd(String sms) {
  return hasTransactionKeywords(sms);
}
