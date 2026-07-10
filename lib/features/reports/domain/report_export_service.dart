import 'package:spendsense/features/reports/domain/report_format.dart';
import 'package:spendsense/features/reports/domain/report_snapshot.dart';

sealed class ReportExportResult {
  const ReportExportResult();

  const factory ReportExportResult.success(String filePath) =
      ReportExportSuccess;
  const factory ReportExportResult.failure(Object error) = ReportExportFailure;
}

final class ReportExportSuccess extends ReportExportResult {
  const ReportExportSuccess(this.filePath);

  final String filePath;
}

final class ReportExportFailure extends ReportExportResult {
  const ReportExportFailure(this.error);

  final Object error;
}

abstract class ReportExportService {
  Future<ReportExportResult> export({
    required ReportFormat format,
    required ReportSnapshot snapshot,
  });

  Future<void> shareExportedFile(String filePath);

  Future<void> presentExportedFile({
    required ReportFormat format,
    required String filePath,
  });
}

String formatReportFileName({
  required ReportFormat format,
  required DateTime exportedAt,
}) {
  final year = exportedAt.year.toString().padLeft(4, '0');
  final month = exportedAt.month.toString().padLeft(2, '0');
  final day = exportedAt.day.toString().padLeft(2, '0');
  return 'SpendSense_Report_$year-$month-$day.${format.extension}';
}
