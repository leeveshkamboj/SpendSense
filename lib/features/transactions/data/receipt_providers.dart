import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/transactions/data/platform_receipt_file_gateway.dart';
import 'package:spendsense/features/transactions/data/receipt_file_gateway.dart';
import 'package:spendsense/features/transactions/data/receipt_repository.dart';
import 'package:spendsense/features/transactions/data/receipt_service.dart';
import 'package:spendsense/features/transactions/data/receipt_storage_service.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(ref.watch(databaseProvider));
});

final receiptFileGatewayProvider = Provider<ReceiptFileGateway>(
  (ref) => PlatformReceiptFileGateway(),
);

final receiptsDirectoryProvider = FutureProvider<String>((ref) async {
  final directory = await getApplicationDocumentsDirectory();
  return p.join(directory.path, 'receipts');
});

final receiptStorageServiceProvider =
    FutureProvider<ReceiptStorageService>((ref) async {
  final directory = await ref.watch(receiptsDirectoryProvider.future);
  return ReceiptStorageService(receiptsDirectory: directory);
});

final receiptServiceProvider = FutureProvider<ReceiptService>((ref) async {
  return ReceiptService(
    repository: ref.watch(receiptRepositoryProvider),
    storage: await ref.watch(receiptStorageServiceProvider.future),
    fileGateway: ref.watch(receiptFileGatewayProvider),
  );
});
