import 'dart:io';

class LocalAutoBackupStore {
  LocalAutoBackupStore(this._directoryPath);

  final String _directoryPath;

  Future<Directory> ensureDirectory() async {
    final directory = Directory(_directoryPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<List<File>> listBackupFiles() async {
    final directory = await ensureDirectory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.ssb'))
        .toList()
      ..sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
    return files;
  }

  Future<DateTime?> latestBackupAt() async {
    final files = await listBackupFiles();
    if (files.isEmpty) {
      return null;
    }
    return files.first.lastModifiedSync();
  }

  Future<String> backupPathFor(DateTime date) async {
    final directory = await ensureDirectory();
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${directory.path}/SpendSense_Backup_$year-$month-$day.ssb';
  }

  Future<void> pruneToKeepLast(int count) async {
    final files = await listBackupFiles();
    for (final file in files.skip(count)) {
      await file.delete();
    }
  }
}
