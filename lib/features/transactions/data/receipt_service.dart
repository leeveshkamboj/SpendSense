import 'package:spendsense/features/transactions/data/receipt_file_gateway.dart';
import 'package:spendsense/features/transactions/data/receipt_repository.dart';
import 'package:spendsense/features/transactions/data/receipt_storage_service.dart';

class ReceiptService {
  ReceiptService({
    required ReceiptRepository repository,
    required ReceiptStorageService storage,
    required ReceiptFileGateway fileGateway,
  })  : _repository = repository,
        _storage = storage,
        _fileGateway = fileGateway;

  final ReceiptRepository _repository;
  final ReceiptStorageService _storage;
  final ReceiptFileGateway _fileGateway;

  Future<List<TransactionReceipt>> listForTransaction(int transactionId) {
    return _repository.listReceiptsForTransaction(transactionId);
  }

  Future<bool> pickAndAttachReceipt(int transactionId) async {
    final pickedPath = await _fileGateway.pickReceiptFile();
    if (pickedPath == null) {
      return false;
    }

    final storedPath = await _storage.importReceipt(
      transactionId: transactionId,
      sourcePath: pickedPath,
    );
    await _repository.add(
      transactionId: transactionId,
      filePath: storedPath,
    );
    return true;
  }

  Future<void> removeReceipt(TransactionReceipt receipt) async {
    await _repository.remove(receipt.id);
    await _storage.deleteReceiptFile(receipt.filePath);
  }
}
