import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/backup/data/auto_backup_service.dart';
import 'package:spendsense/features/backup/data/backup_repository.dart';
import 'package:spendsense/features/backup/data/local_auto_backup_store.dart';
import 'package:spendsense/features/backup/data/memory_backup_password_store.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';

void main() {
  group('AutoBackupService', () {
    late Directory tempDir;
    late Directory backupDir;
    late AppDatabase database;
    late BackupRepository repository;
    late MemoryBackupPasswordStore passwordStore;
    late LocalAutoBackupStore store;
    late AutoBackupService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('auto_backup_service_');
      backupDir = Directory('${tempDir.path}/backups')..createSync();
      final databasePath = '${tempDir.path}/spendsense.sqlite';
      database = AppDatabase(NativeDatabase(File(databasePath)));
      repository = BackupRepository(
        database: database,
        databaseFilePath: databasePath,
      );
      passwordStore = MemoryBackupPasswordStore();
      await passwordStore.savePassword('weekly-secret');
      store = LocalAutoBackupStore(backupDir.path);
      service = AutoBackupService(
        repository: repository,
        passwordStore: passwordStore,
        store: store,
      );
      await CreditCardRepository(database).create(
        const NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: 'HDFC ••5534',
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
    });

    tearDown(() async {
      await database.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('skips when the latest backup is within seven days', () async {
      final existing = File('${backupDir.path}/SpendSense_Backup_2026-07-03.ssb');
      await existing.writeAsBytes([1, 2, 3]);
      await existing.setLastModified(DateTime(2026, 7, 8));

      final result = await service.runIfDue(asOf: DateTime(2026, 7, 10));

      expect(result, isA<AutoBackupSkipped>());
      expect(await store.listBackupFiles(), hasLength(1));
    });

    test('creates encrypted backup when due and prunes to four files', () async {
      for (var day = 1; day <= 4; day++) {
        final file = File('${backupDir.path}/SpendSense_Backup_2026-07-0$day.ssb');
        await file.writeAsBytes([day]);
        await file.setLastModified(DateTime(2026, 6, day));
      }

      final result = await service.runIfDue(asOf: DateTime(2026, 7, 10));

      expect(result, isA<AutoBackupSuccess>());
      final files = await store.listBackupFiles();
      expect(files, hasLength(4));
      expect(files.first.path, endsWith('SpendSense_Backup_2026-07-10.ssb'));
      expect(files.first.readAsBytesSync().length, greaterThan(10));
    });
  });
}
