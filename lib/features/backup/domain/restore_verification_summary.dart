class RestoreVerificationSummary {
  const RestoreVerificationSummary({
    required this.backupDate,
    required this.cardNicknames,
  });

  final DateTime backupDate;
  final List<String> cardNicknames;
}
