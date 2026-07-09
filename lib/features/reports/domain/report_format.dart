enum ReportFormat {
  pdf('pdf', 'application/pdf'),
  csv('csv', 'text/csv'),
  excel('xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');

  const ReportFormat(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}
