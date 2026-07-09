import 'package:drift/drift.dart';
import 'package:spendsense/core/database/database.dart';

class NewBankAccount {
  const NewBankAccount({
    required this.bank,
    required this.lastFourDigits,
    required this.nickname,
    required this.colorValue,
    required this.iconName,
    this.openingBalancePaise = 0,
    this.notes,
  });

  final String bank;
  final String lastFourDigits;
  final String nickname;
  final int openingBalancePaise;
  final int colorValue;
  final String iconName;
  final String? notes;
}

class BankAccountRepository {
  BankAccountRepository(this._database);

  final AppDatabase _database;

  Future<int> create(NewBankAccount account) {
    return _database.into(_database.bankAccounts).insert(
          BankAccountsCompanion.insert(
            bank: account.bank,
            lastFourDigits: account.lastFourDigits,
            nickname: account.nickname,
            openingBalancePaise: Value(account.openingBalancePaise),
            colorValue: account.colorValue,
            iconName: account.iconName,
            notes: Value(account.notes),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<BankAccount?> getById(int id) {
    return (_database.select(_database.bankAccounts)
          ..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<BankAccount?> findByBankAndLastFour({
    required String bank,
    required String lastFourDigits,
  }) {
    return (_database.select(_database.bankAccounts)
          ..where(
            (row) =>
                row.bank.equals(bank) &
                row.lastFourDigits.equals(lastFourDigits),
          ))
        .getSingleOrNull();
  }

  Future<int> autoCreateFromSms({
    required String bank,
    required String lastFourDigits,
  }) {
    return create(
      NewBankAccount(
        bank: bank,
        lastFourDigits: lastFourDigits,
        nickname: '$bank ••$lastFourDigits',
        colorValue: 0xFF1565C0,
        iconName: 'account_balance',
      ),
    );
  }

  Future<List<BankAccount>> listActive() {
    return (_database.select(_database.bankAccounts)
          ..where((row) => row.isArchived.equals(false))
          ..orderBy([(row) => OrderingTerm.asc(row.nickname)]))
        .get();
  }
}
