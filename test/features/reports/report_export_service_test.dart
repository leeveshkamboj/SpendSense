import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/reports/data/live_report_export_service.dart';
import 'package:spendsense/features/reports/data/report_share_gateway.dart';
import 'package:spendsense/features/reports/domain/report_export_service.dart';
import 'package:spendsense/features/reports/domain/report_format.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';

class _RecordingShareGateway implements ReportShareGateway {
  String? lastFilePath;
  String? lastMimeType;
  String? lastSubject;
  String? lastOpenedFilePath;
  String? lastOpenedMimeType;

  @override
  Future<void> shareFile({
    required String filePath,
    required String mimeType,
    required String subject,
  }) async {
    lastFilePath = filePath;
    lastMimeType = mimeType;
    lastSubject = subject;
  }

  @override
  Future<void> openFile({
    required String filePath,
    required String mimeType,
  }) async {
    lastOpenedFilePath = filePath;
    lastOpenedMimeType = mimeType;
  }
}

void main() {
  group('LiveReportExportService', () {
    late Directory tempDir;
    late _RecordingShareGateway shareGateway;
    late LiveReportExportService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('report_export_test_');
      shareGateway = _RecordingShareGateway();
      service = LiveReportExportService(
        shareGateway: shareGateway,
        tempDirectoryProvider: () async => tempDir,
      );
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    ReportSnapshot emptySnapshot() {
      return ReportSnapshot(
        exportedAt: DateTime(2026, 7, 10),
        cardTransactions: const [],
        billingCycles: const [],
        categories: const [],
        accounts: const [],
        monthlyBudget: null,
        categoryBudgets: const [],
        bills: const [],
        analytics: null,
        recoverablesByPerson: const {'Alex Kumar': 50000},
      );
    }

    test('writes CSV export to a temp file', () async {
      final result = await service.export(
        format: ReportFormat.csv,
        snapshot: emptySnapshot(),
      );

      expect(result, isA<ReportExportSuccess>());
      final path = (result as ReportExportSuccess).filePath;
      expect(path, endsWith('.csv'));
      expect(File(path).existsSync(), isTrue);
      expect(File(path).readAsStringSync(), contains('Alex Kumar'));
    });

    test('opens share sheet for generated file', () async {
      final exportResult = await service.export(
        format: ReportFormat.csv,
        snapshot: emptySnapshot(),
      );
      final path = (exportResult as ReportExportSuccess).filePath;

      await service.shareExportedFile(path);

      expect(shareGateway.lastFilePath, path);
      expect(shareGateway.lastMimeType, ReportFormat.csv.mimeType);
      expect(shareGateway.lastSubject, isNotNull);
    });

    test('opens exported files directly', () async {
      for (final format in ReportFormat.values) {
        final exportResult = await service.export(
          format: format,
          snapshot: emptySnapshot(),
        );
        final path = (exportResult as ReportExportSuccess).filePath;

        await service.presentExportedFile(format: format, filePath: path);

        expect(shareGateway.lastOpenedFilePath, path);
        expect(shareGateway.lastOpenedMimeType, format.mimeType);
        expect(shareGateway.lastFilePath, isNull);
      }
    });
  });
}
