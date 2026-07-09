class BackupWrongPasswordException implements Exception {
  BackupWrongPasswordException(this.fileName);

  final String fileName;

  @override
  String toString() => 'Wrong password for backup file $fileName';
}

class BackupCorruptFileException implements Exception {
  BackupCorruptFileException(this.fileName, {this.reason});

  final String fileName;
  final String? reason;

  @override
  String toString() {
    final detail = reason == null ? '' : ': $reason';
    return 'Corrupt backup file $fileName$detail';
  }
}
