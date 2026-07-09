import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

const builtInSmsSenders = [
  'VM-HDFCBK',
  'AD-HDFCBK',
  'VM-SBICRD',
  'JD-SBIINB',
  'VM-ICICIB',
  'AD-ICICIB',
  'VM-AXISBK',
  'AD-AXISBK',
  'VM-KOTAKB',
  'AD-KOTAKB',
];

class SmsSenderRepository {
  SmsSenderRepository(this._database);

  final AppDatabase _database;

  Future<void> ensureBuiltInSenders() async {
    final existing = await listAll();
    if (existing.isNotEmpty) {
      return;
    }

    await _database.batch((batch) {
      for (final address in builtInSmsSenders) {
        batch.insert(
          _database.smsSenders,
          SmsSendersCompanion.insert(address: address, isBuiltIn: const Value(true)),
        );
      }
    });
  }

  Future<List<SmsSender>> listAll() {
    return (_database.select(_database.smsSenders)
          ..orderBy([
            (row) => OrderingTerm.desc(row.isBuiltIn),
            (row) => OrderingTerm.asc(row.address),
          ]))
        .get();
  }

  Future<void> addCustomSender(String address) async {
    final normalized = address.trim().toUpperCase();
    if (normalized.isEmpty) {
      return;
    }

    final existing = await (_database.select(_database.smsSenders)
          ..where((row) => row.address.equals(normalized)))
        .getSingleOrNull();
    if (existing != null) {
      return;
    }

    await _database.into(_database.smsSenders).insert(
          SmsSendersCompanion.insert(address: normalized),
        );
  }

  Future<void> removeCustomSender(int id) async {
    await (_database.delete(_database.smsSenders)
          ..where((row) => row.id.equals(id) & row.isBuiltIn.equals(false)))
        .go();
  }

  Future<bool> isWhitelisted(String sender) async {
    final normalized = sender.trim().toUpperCase();
    final row = await (_database.select(_database.smsSenders)
          ..where((row) => row.address.equals(normalized)))
        .getSingleOrNull();
    return row != null;
  }
}

bool isSenderWhitelisted({
  required String sender,
  required Set<String> whitelist,
}) {
  return whitelist.contains(sender.trim().toUpperCase());
}

List<String> filterMessagesBySender({
  required List<({String sender, String body})> messages,
  required Set<String> whitelist,
}) {
  return messages
      .where((message) => isSenderWhitelisted(
            sender: message.sender,
            whitelist: whitelist,
          ))
      .map((message) => message.body)
      .toList();
}
