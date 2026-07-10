import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spendsense/features/transactions/data/receipt_providers.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/backup/data/auto_backup_service.dart';
import 'package:spendsense/features/backup/data/backup_file_gateway.dart';
import 'package:spendsense/features/backup/data/backup_password_store.dart';
import 'package:spendsense/features/backup/data/backup_repository.dart';
import 'package:spendsense/features/backup/data/backup_service.dart';
import 'package:spendsense/features/backup/data/local_auto_backup_store.dart';
import 'package:spendsense/features/backup/data/platform_backup_file_gateway.dart';
import 'package:spendsense/features/backup/data/secure_backup_password_store.dart';
import 'package:spendsense/features/backup/domain/backup_exception.dart';

final backupFileGatewayProvider = Provider<BackupFileGateway>(
  (ref) => PlatformBackupFileGateway(),
);

final databaseFilePathProvider = FutureProvider<String>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  return p.join(directory.path, 'spendsense.sqlite');
});

final backupRepositoryProvider = FutureProvider<BackupRepository>((ref) async {
  final database = ref.watch(databaseProvider);
  final databaseFilePath = await ref.watch(databaseFilePathProvider.future);
  final receiptsDirectory = await ref.watch(receiptsDirectoryProvider.future);
  return BackupRepository(
    database: database,
    databaseFilePath: databaseFilePath,
    receiptsDirectoryPath: receiptsDirectory,
  );
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return LiveBackupService(
    ref: ref,
    fileGateway: ref.watch(backupFileGatewayProvider),
    passwordStore: ref.watch(backupPasswordStoreProvider),
  );
});

final backupPasswordStoreProvider = Provider<BackupPasswordStore>(
  (ref) => SecureBackupPasswordStore(),
);

final autoBackupDirectoryProvider = FutureProvider<String>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  return p.join(directory.path, 'auto_backups');
});

final localAutoBackupStoreProvider = FutureProvider<LocalAutoBackupStore>((ref) async {
  final directory = await ref.watch(autoBackupDirectoryProvider.future);
  return LocalAutoBackupStore(directory);
});

final autoBackupServiceProvider = FutureProvider<AutoBackupService>((ref) async {
  final repository = await ref.watch(backupRepositoryProvider.future);
  final store = await ref.watch(localAutoBackupStoreProvider.future);
  return AutoBackupService(
    repository: repository,
    passwordStore: ref.watch(backupPasswordStoreProvider),
    store: store,
  );
});

final autoBackupFailureProvider = StateProvider<String?>((ref) => null);

final autoBackupSyncProvider = FutureProvider<void>((ref) async {
  final service = await ref.watch(autoBackupServiceProvider.future);
  final result = await service.runIfDue(asOf: DateTime.now());

  switch (result) {
    case AutoBackupSkipped():
    case AutoBackupNoPassword():
      return;
    case AutoBackupSuccess():
      ref.read(autoBackupFailureProvider.notifier).state = null;
    case AutoBackupFailure(:final error):
      ref.read(autoBackupFailureProvider.notifier).state = '$error';
  }
});

class LiveBackupService implements BackupService {
  LiveBackupService({
    required Ref ref,
    required BackupFileGateway fileGateway,
    required BackupPasswordStore passwordStore,
  })  : _ref = ref,
        _fileGateway = fileGateway,
        _passwordStore = passwordStore;

  final Ref _ref;
  final BackupFileGateway _fileGateway;
  final BackupPasswordStore _passwordStore;

  @override
  Future<String?> pickBackupFile() {
    return _fileGateway.pickBackupFile();
  }

  @override
  Future<BackupActionResult> exportSalvageBackup({
    required String sourceBackupPath,
  }) async {
    final destination = await _fileGateway.pickExportDestination(
      sourceBackupPath.split(Platform.pathSeparator).last,
    );
    if (destination == null) {
      return const BackupActionResult.cancelled();
    }

    try {
      await File(sourceBackupPath).copy(destination);
      return const BackupActionResult.success('Salvage backup exported');
    } catch (error) {
      return BackupActionResult.failure(error);
    }
  }

  @override
  Future<BackupActionResult> exportBackup({required String password}) async {
    final destination = await _fileGateway.pickExportDestination(
      formatBackupFileName(DateTime.now()),
    );
    if (destination == null) {
      return const BackupActionResult.cancelled();
    }

    try {
      final repository = await _ref.read(backupRepositoryProvider.future);
      await repository.exportEncrypted(
        password: password,
        destinationPath: destination,
      );
      await _passwordStore.savePassword(password);
      return const BackupActionResult.success('Backup saved');
    } catch (error) {
      return BackupActionResult.failure(error);
    }
  }

  @override
  Future<BackupActionResult> restoreBackup({
    required String backupFilePath,
    required String password,
  }) async {
    try {
      final repository = await _ref.read(backupRepositoryProvider.future);
      final metadata = await repository.restoreEncrypted(
        backupFilePath: backupFilePath,
        password: password,
      );
      await _passwordStore.savePassword(password);
      _ref.invalidate(databaseProvider);
      _ref.invalidate(backupRepositoryProvider);
      return BackupActionResult.success(
        'Backup restored',
        metadata: metadata,
      );
    } on BackupWrongPasswordException catch (error) {
      return BackupActionResult.failure(error);
    } on BackupCorruptFileException catch (error) {
      return BackupActionResult.failure(error);
    } catch (error) {
      return BackupActionResult.failure(error);
    }
  }
}
