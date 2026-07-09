import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/backup/data/local_auto_backup_store.dart';

void main() {
  group('LocalAutoBackupStore', () {
    late Directory tempDir;
    late LocalAutoBackupStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('auto_backup_store_');
      store = LocalAutoBackupStore(tempDir.path);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('prune keeps only the four newest backup files', () async {
      for (var day = 1; day <= 5; day++) {
        final file = File('${tempDir.path}/SpendSense_Backup_2026-07-0$day.ssb');
        await file.writeAsString('backup-$day');
        await file.setLastModified(DateTime(2026, 7, day));
      }

      await store.pruneToKeepLast(4);

      final remaining = await store.listBackupFiles();
      expect(remaining, hasLength(4));
      expect(
        remaining.map((file) => file.path.split('/').last).toList(),
        [
          'SpendSense_Backup_2026-07-05.ssb',
          'SpendSense_Backup_2026-07-04.ssb',
          'SpendSense_Backup_2026-07-03.ssb',
          'SpendSense_Backup_2026-07-02.ssb',
        ],
      );
    });
  });
}
