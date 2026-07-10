import 'package:file_picker/file_picker.dart';
import 'package:spendsense/features/transactions/data/receipt_file_gateway.dart';

class PlatformReceiptFileGateway implements ReceiptFileGateway {
  @override
  Future<String?> pickReceiptFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'heic', 'pdf'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    return result.files.single.path;
  }
}
