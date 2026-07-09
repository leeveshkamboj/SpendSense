class BackupMetadata {
  const BackupMetadata({
    required this.exportedAt,
    required this.schemaVersion,
  });

  final DateTime exportedAt;
  final int schemaVersion;
}
