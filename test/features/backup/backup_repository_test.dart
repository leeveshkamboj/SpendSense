import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/backup/data/backup_repository.dart';
import 'package:spendsense/features/backup/domain/backup_exception.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';

void main() {
  group('BackupRepository', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('backup_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('export and restore preserves credit card data', () async {
      final sourcePath = '${tempDir.path}/source.db';
      final sourceDb = AppDatabase(NativeDatabase(File(sourcePath)));
      final creditCards = CreditCardRepository(sourceDb);
      await creditCards.create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      final backupPath = '${tempDir.path}/SpendSense_Backup_2026-07-10.ssb';
      final backup = BackupRepository(
        database: sourceDb,
        databaseFilePath: sourcePath,
      );
      final exportedAt = await backup.exportEncrypted(
        password: 'strong-password',
        destinationPath: backupPath,
      );
      await sourceDb.close();

      expect(File(backupPath).existsSync(), isTrue);
      expect(exportedAt, isNotNull);

      final targetPath = '${tempDir.path}/target.db';
      final targetDb = AppDatabase(NativeDatabase(File(targetPath)));
      await targetDb.close();

      final restore = BackupRepository(
        database: AppDatabase(NativeDatabase(File(targetPath))),
        databaseFilePath: targetPath,
      );
      final metadata = await restore.restoreEncrypted(
        backupFilePath: backupPath,
        password: 'strong-password',
      );

      expect(metadata.exportedAt, exportedAt);

      final restoredDb = AppDatabase(NativeDatabase(File(targetPath)));
      final restoredCards = await CreditCardRepository(restoredDb).listActive();
      await restoredDb.close();

      expect(restoredCards, hasLength(1));
      expect(restoredCards.first.nickname, 'HDFC ••5534');
      expect(restoredCards.first.bank, 'HDFC');
    });

    test('restore rejects wrong password with filename', () async {
      final sourcePath = '${tempDir.path}/source.db';
      final sourceDb = AppDatabase(NativeDatabase(File(sourcePath)));
      await CreditCardRepository(sourceDb).create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );

      final backupPath = '${tempDir.path}/backup.ssb';
      final backup = BackupRepository(
        database: sourceDb,
        databaseFilePath: sourcePath,
      );
      await backup.exportEncrypted(
        password: 'correct-password',
        destinationPath: backupPath,
      );
      await sourceDb.close();

      final targetPath = '${tempDir.path}/target.db';
      final targetDb = AppDatabase(NativeDatabase(File(targetPath)));
      await targetDb.close();

      final restore = BackupRepository(
        database: AppDatabase(NativeDatabase(File(targetPath))),
        databaseFilePath: targetPath,
      );

      expect(
        () => restore.restoreEncrypted(
          backupFilePath: backupPath,
          password: 'wrong-password',
        ),
        throwsA(
          isA<BackupWrongPasswordException>().having(
            (error) => error.fileName,
            'fileName',
            'backup.ssb',
          ),
        ),
      );
    });
    test('restore rejects corrupt backup file', () async {
      final backupPath = '${tempDir.path}/broken.ssb';
      await File(backupPath).writeAsBytes([1, 2, 3, 4]);

      final targetPath = '${tempDir.path}/target.db';
      final targetDb = AppDatabase(NativeDatabase(File(targetPath)));
      await targetDb.close();

      final restore = BackupRepository(
        database: AppDatabase(NativeDatabase(File(targetPath))),
        databaseFilePath: targetPath,
      );

      expect(
        () => restore.restoreEncrypted(
          backupFilePath: backupPath,
          password: 'any-password',
        ),
        throwsA(
          isA<BackupCorruptFileException>().having(
            (error) => error.fileName,
            'fileName',
            'broken.ssb',
          ),
        ),
      );
    });
  });
}
