import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spendsense/features/reports/domain/report_export_service.dart';
import 'package:spendsense/features/reports/domain/report_format.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';
import 'package:spendsense/features/reports/data/report_share_gateway.dart';
import 'package:spendsense/features/reports/engine/report_csv_encoder.dart';
import 'package:spendsense/features/reports/engine/report_excel_encoder.dart';
import 'package:spendsense/features/reports/engine/report_pdf_encoder.dart';

class LiveReportExportService implements ReportExportService {
  LiveReportExportService({
    required ReportShareGateway shareGateway,
    Future<Directory> Function()? tempDirectoryProvider,
  })  : _shareGateway = shareGateway,
        _tempDirectoryProvider =
            tempDirectoryProvider ?? getTemporaryDirectory;

  final ReportShareGateway _shareGateway;
  final Future<Directory> Function() _tempDirectoryProvider;

  @override
  Future<ReportExportResult> export({
    required ReportFormat format,
    required ReportSnapshot snapshot,
  }) async {
    try {
      final bytes = await _encode(format: format, snapshot: snapshot);
      final directory = await _tempDirectoryProvider();
      final fileName = formatReportFileName(
        format: format,
        exportedAt: snapshot.exportedAt,
      );
      final filePath = p.join(directory.path, fileName);
      await File(filePath).writeAsBytes(bytes);
      return ReportExportResult.success(filePath);
    } catch (error) {
      return ReportExportResult.failure(error);
    }
  }

  @override
  Future<void> shareExportedFile(String filePath) async {
    final extension = p.extension(filePath).replaceFirst('.', '');
    final format = ReportFormat.values.firstWhere(
      (candidate) => candidate.extension == extension,
      orElse: () => ReportFormat.pdf,
    );
    await _shareGateway.shareFile(
      filePath: filePath,
      mimeType: format.mimeType,
      subject: p.basenameWithoutExtension(filePath),
    );
  }

  Future<Uint8List> _encode({
    required ReportFormat format,
    required ReportSnapshot snapshot,
  }) {
    return switch (format) {
      ReportFormat.csv => Future.value(
          Uint8List.fromList(ReportCsvEncoder.encode(snapshot).codeUnits),
        ),
      ReportFormat.excel =>
        Future.value(ReportExcelEncoder.encode(snapshot)),
      ReportFormat.pdf => ReportPdfEncoder.encode(snapshot),
    };
  }
}
