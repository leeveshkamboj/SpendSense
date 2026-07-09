import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/backup/data/backup_providers.dart';
import 'package:spendsense/features/backup/data/backup_service.dart';
import 'package:spendsense/features/backup/domain/backup_exception.dart';
import 'package:spendsense/features/backup/domain/backup_metadata.dart';
import 'package:spendsense/features/backup/presentation/backup_settings_screen.dart';
import 'package:spendsense/features/settings/presentation/settings_screen.dart';

class _FakeBackupService implements BackupService {
  _FakeBackupService({
    this.exportResult = const BackupActionResult.success('Backup saved'),
    this.restoreResult = const BackupActionResult.success('Backup restored'),
  });

  BackupActionResult exportResult;
  BackupActionResult restoreResult;
  String? lastExportPassword;
  String? lastRestorePassword;
  String? lastRestorePath;

  @override
  Future<BackupActionResult> exportBackup({required String password}) async {
    lastExportPassword = password;
    return exportResult;
  }

  @override
  Future<BackupActionResult> restoreBackup({
    required String backupFilePath,
    required String password,
  }) async {
    lastRestorePassword = password;
    lastRestorePath = backupFilePath;
    return restoreResult;
  }

  @override
  Future<String?> pickBackupFile() async => '/tmp/SpendSense_Backup_2026-07-10.ssb';

  @override
  Future<BackupActionResult> exportSalvageBackup({
    required String sourceBackupPath,
  }) async {
    return const BackupActionResult.success('Salvage backup exported');
  }
}

void main() {
  group('Backup settings', () {
    testWidgets('settings screen links to backup and restore', (tester) async {
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'backup',
                builder: (context, state) => const BackupSettingsScreen(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBudgetsProvider.overrideWith((ref) async => []),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Backup & Restore'), findsOneWidget);
      await tester.tap(find.text('Backup & Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Export backup'), findsOneWidget);
      expect(find.text('Restore from backup'), findsOneWidget);
    });

    testWidgets('export backup asks for password and calls backup service', (
      tester,
    ) async {
      final service = _FakeBackupService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backupServiceProvider.overrideWithValue(service),
          ],
          child: const MaterialApp(home: BackupSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export backup'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'my-secret');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(service.lastExportPassword, 'my-secret');
      expect(find.text('Backup saved'), findsOneWidget);
    });

    testWidgets('restore shows wrong password error with filename', (
      tester,
    ) async {
      final service = _FakeBackupService(
        restoreResult: BackupActionResult.failure(
          BackupWrongPasswordException('SpendSense_Backup_2026-07-10.ssb'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backupServiceProvider.overrideWithValue(service),
          ],
          child: const MaterialApp(home: BackupSettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore from backup'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'wrong-password');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(service.lastRestorePath, '/tmp/SpendSense_Backup_2026-07-10.ssb');
      expect(
        find.textContaining('SpendSense_Backup_2026-07-10.ssb'),
        findsOneWidget,
      );
      expect(find.textContaining('Wrong password'), findsOneWidget);
    });
  });
}
