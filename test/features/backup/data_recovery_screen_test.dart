import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/backup/presentation/data_recovery_screen.dart';

void main() {
  group('Data recovery screen', () {
    testWidgets('offers restore, export, and reset with latest backup selected', (
      tester,
    ) async {
      var restored = false;
      var exported = false;
      var reset = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DataRecoveryScreen(
            localBackups: const [
              '/data/auto_backups/SpendSense_Backup_2026-07-10.ssb',
              '/data/auto_backups/SpendSense_Backup_2026-07-03.ssb',
            ],
            onRestore: (_) => restored = true,
            onExportSalvage: () => exported = true,
            onReset: () => reset = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Data Recovery'), findsOneWidget);
      expect(find.textContaining('2026-07-10'), findsOneWidget);
      expect(find.text('Restore from backup'), findsOneWidget);
      expect(find.text('Export salvageable data'), findsOneWidget);
      expect(find.text('Reset app'), findsOneWidget);

      await tester.tap(find.text('Restore from backup'));
      await tester.pumpAndSettle();
      expect(restored, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: DataRecoveryScreen(
            localBackups: const [
              '/data/auto_backups/SpendSense_Backup_2026-07-10.ssb',
            ],
            onRestore: (_) {},
            onExportSalvage: () => exported = true,
            onReset: () => reset = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export salvageable data'));
      await tester.pumpAndSettle();
      expect(exported, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: DataRecoveryScreen(
            localBackups: const [],
            onRestore: (_) {},
            onExportSalvage: () {},
            onReset: () => reset = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset app'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(reset, isTrue);
    });
  });
}
