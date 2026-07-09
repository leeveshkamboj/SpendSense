enum SmsCaptureResult {
  captured,
  duplicate,
  ignored,
}

class CaptureNotificationEvent {
  const CaptureNotificationEvent({
    required this.transactionId,
    required this.amountPaise,
    required this.merchant,
    required this.cardNickname,
    this.isBankAccount = false,
  });

  final int transactionId;
  final int amountPaise;
  final String merchant;
  final String cardNickname;
  final bool isBankAccount;
}
