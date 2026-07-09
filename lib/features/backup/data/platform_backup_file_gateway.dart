import 'package:file_picker/file_picker.dart';
import 'package:spendsense/features/backup/data/backup_file_gateway.dart';

class PlatformBackupFileGateway implements BackupFileGateway {
  @override
  Future<String?> pickBackupFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['ssb'],
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }
    return result.files.single.path;
  }

  @override
  Future<String?> pickExportDestination(String suggestedName) async {
    return FilePicker.saveFile(
      fileName: suggestedName,
      type: FileType.custom,
      allowedExtensions: const ['ssb'],
    );
  }
}
