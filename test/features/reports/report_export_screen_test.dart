import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/reports/data/live_report_export_service.dart';
import 'package:spendsense/features/reports/data/report_providers.dart';
import 'package:spendsense/features/reports/data/report_share_gateway.dart';
import 'package:spendsense/features/reports/presentation/report_export_screen.dart';

class _RecordingShareGateway implements ReportShareGateway {
  var shareCount = 0;

  @override
  Future<void> shareFile({
    required String filePath,
    required String mimeType,
    required String subject,
  }) async {
    shareCount++;
  }
}

void main() {
  group('ReportExportScreen', () {
    late AppDatabase database;
    late Directory tempDir;
    late _RecordingShareGateway shareGateway;

    setUp(() async {
      database = AppDatabase(NativeDatabase.memory());
      tempDir = await Directory.systemTemp.createTemp('report_screen_test_');
      shareGateway = _RecordingShareGateway();
    });

    tearDown(() async {
      await database.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            reportShareGatewayProvider.overrideWithValue(shareGateway),
            reportExportServiceProvider.overrideWithValue(
              LiveReportExportService(
                shareGateway: shareGateway,
                tempDirectoryProvider: () async => tempDir,
              ),
            ),
          ],
          child: const MaterialApp(home: ReportExportScreen()),
        ),
      );
    }

    testWidgets('offers PDF CSV and Excel export buttons', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Export PDF'), findsOneWidget);
      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.text('Export Excel'), findsOneWidget);
    });
  });
}
