import 'package:spendsense/features/backup/domain/backup_metadata.dart';
import 'package:spendsense/features/backup/domain/restore_verification_summary.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';

Future<RestoreVerificationSummary> loadRestoreVerificationSummary(
  CreditCardRepository creditCards,
  BackupMetadata metadata,
) async {
  final cards = await creditCards.listActive();

  return RestoreVerificationSummary(
    backupDate: metadata.exportedAt,
    cardNicknames: cards.map((card) => card.nickname).toList(),
  );
}
