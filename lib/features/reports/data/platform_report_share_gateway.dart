import 'dart:io';

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
}
