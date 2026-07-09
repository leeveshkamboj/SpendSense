abstract class ReportShareGateway {
  Future<void> shareFile({
    required String filePath,
    required String mimeType,
    required String subject,
  });
}
