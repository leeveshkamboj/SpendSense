import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spendsense/features/reports/data/report_share_gateway.dart';

class PlatformReportShareGateway implements ReportShareGateway {
  @override
  Future<void> shareFile({
    required String filePath,
    required String mimeType,
    required String subject,
  }) {
    return Share.shareXFiles(
      [XFile(filePath, mimeType: mimeType)],
      subject: subject,
    );
  }

  @override
  Future<void> openFile({
    required String filePath,
    required String mimeType,
  }) async {
    final result = await OpenFilex.open(filePath, type: mimeType);
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }
}
