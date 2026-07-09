import 'package:spendsense/features/backup/data/backup_password_store.dart';
import 'package:spendsense/features/backup/data/backup_repository.dart';
import 'package:spendsense/features/backup/data/local_auto_backup_store.dart';

sealed class AutoBackupResult {
  const AutoBackupResult();
}

final class AutoBackupSkipped extends AutoBackupResult {
  const AutoBackupSkipped();
}

final class AutoBackupNoPassword extends AutoBackupResult {
  const AutoBackupNoPassword();
}

final class AutoBackupSuccess extends AutoBackupResult {
  const AutoBackupSuccess(this.backupPath);

  final String backupPath;
}

final class AutoBackupFailure extends AutoBackupResult {
  const AutoBackupFailure(this.error);

  final Object error;
}

class AutoBackupService {
  AutoBackupService({
    required BackupRepository repository,
    required BackupPasswordStore passwordStore,
    required LocalAutoBackupStore store,
    this.backupInterval = const Duration(days: 7),
    this.retentionCount = 4,
  })  : _repository = repository,
        _passwordStore = passwordStore,
        _store = store;

  final BackupRepository _repository;
  final BackupPasswordStore _passwordStore;
  final LocalAutoBackupStore _store;
  final Duration backupInterval;
  final int retentionCount;

  Future<AutoBackupResult> runIfDue({required DateTime asOf}) async {
    final latest = await _store.latestBackupAt();
    if (latest != null && asOf.difference(latest) < backupInterval) {
      return const AutoBackupSkipped();
    }
    return runNow(asOf: asOf);
  }

  Future<AutoBackupResult> runNow({
    required DateTime asOf,
    String? passwordOverride,
  }) async {
    final password = passwordOverride ?? await _passwordStore.readPassword();
    if (password == null || password.isEmpty) {
      return const AutoBackupNoPassword();
    }

    try {
      final destination = await _store.backupPathFor(asOf);
      await _repository.exportEncrypted(
        password: password,
        destinationPath: destination,
      );
      await _store.pruneToKeepLast(retentionCount);
      return AutoBackupSuccess(destination);
    } catch (error) {
      return AutoBackupFailure(error);
    }
  }
}
