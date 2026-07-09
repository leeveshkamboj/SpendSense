import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/backup/data/backup_providers.dart';
import 'package:spendsense/features/backup/data/database_health_checker.dart';
import 'package:spendsense/features/backup/data/backup_service.dart';
import 'package:spendsense/features/backup/presentation/backup_password_dialog.dart';
import 'package:spendsense/features/backup/presentation/data_recovery_screen.dart';
import 'package:spendsense/features/settings/data/app_data_providers.dart';

final databaseHealthCheckerProvider = Provider<DatabaseHealthChecker>(
  (ref) => DatabaseHealthChecker(),
);

final databaseHealthProvider = FutureProvider<bool>((ref) async {
  final database = ref.watch(databaseProvider);
  return ref.watch(databaseHealthCheckerProvider).isHealthy(database);
});

final localBackupPathsProvider = FutureProvider<List<String>>((ref) async {
  final store = await ref.watch(localAutoBackupStoreProvider.future);
  final files = await store.listBackupFiles();
  return files.map((file) => file.path).toList();
});

class DataRecoveryGate extends ConsumerWidget {
  const DataRecoveryGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backups = ref.watch(localBackupPathsProvider);

    return backups.when(
      data: (paths) => DataRecoveryScreen(
        localBackups: paths,
        onRestore: (path) => _restore(context, ref, path),
        onExportSalvage: () => _exportSalvage(context, ref, paths),
        onReset: () => _reset(ref),
      ),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => DataRecoveryScreen(
        localBackups: const [],
        onRestore: (path) => _restore(context, ref, path),
        onExportSalvage: () {},
        onReset: () => _reset(ref),
      ),
    );
  }

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    String backupFilePath,
  ) async {
    final password = await showBackupPasswordDialog(
      context,
      title: 'Restore from backup',
      confirmLabel: 'Restore',
    );
    if (password == null || password.isEmpty || !context.mounted) {
      return;
    }

    final result = await ref.read(backupServiceProvider).restoreBackup(
          backupFilePath: backupFilePath,
          password: password,
        );

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case BackupActionSuccess():
        ref.invalidate(databaseHealthProvider);
      case BackupActionFailure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $error')),
        );
      case BackupActionCancelled():
        return;
    }
  }

  Future<void> _exportSalvage(
    BuildContext context,
    WidgetRef ref,
    List<String> paths,
  ) async {
    if (paths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No local backups to export')),
      );
      return;
    }

    final result = await ref.read(backupServiceProvider).exportSalvageBackup(
          sourceBackupPath: paths.first,
        );

    if (!context.mounted) {
      return;
    }

    switch (result) {
      case BackupActionSuccess(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      case BackupActionFailure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $error')),
        );
      case BackupActionCancelled():
        return;
    }
  }

  Future<void> _reset(WidgetRef ref) async {
    await ref.read(appDataRepositoryProvider).deleteAllData();
    ref.invalidate(databaseProvider);
    ref.invalidate(databaseHealthProvider);
  }
}

class AppHealthGate extends ConsumerWidget {
  const AppHealthGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(databaseHealthProvider);

    return health.when(
      data: (healthy) => healthy ? child : const DataRecoveryGate(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const DataRecoveryGate(),
    );
  }
}
