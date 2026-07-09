import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/sms_capture/data/sms_sender_repository.dart';

void main() {
  group('SmsSenderRepository', () {
    late AppDatabase database;
    late SmsSenderRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = SmsSenderRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('seeds built-in bank senders on first access', () async {
      await repository.ensureBuiltInSenders();

      final senders = await repository.listAll();

      expect(senders, isNotEmpty);
      expect(senders.every((sender) => sender.isBuiltIn), isTrue);
    });

    test('adds and removes custom senders', () async {
      await repository.ensureBuiltInSenders();
      await repository.addCustomSender('VM-MYBANK');

      final senders = await repository.listAll();
      expect(senders.any((sender) => sender.address == 'VM-MYBANK'), isTrue);

      final custom = senders.firstWhere((sender) => sender.address == 'VM-MYBANK');
      await repository.removeCustomSender(custom.id);

      final updated = await repository.listAll();
      expect(updated.any((sender) => sender.address == 'VM-MYBANK'), isFalse);
    });

    test('filters messages by whitelist', () {
      final filtered = filterMessagesBySender(
        messages: [
          (sender: 'VM-HDFCBK', body: 'spent rs 100'),
          (sender: 'VM-RANDOM', body: 'hello'),
        ],
        whitelist: {'VM-HDFCBK'},
      );

      expect(filtered, ['spent rs 100']);
    });
  });
}
