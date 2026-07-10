import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/credit_cards/data/credit_card_repository.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_repository.dart';

void main() {
  group('CreditLimitPoolRepository', () {
    late AppDatabase database;
    late CreditCardRepository creditCards;
    late CreditLimitPoolRepository pools;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      creditCards = CreditCardRepository(database);
      pools = CreditLimitPoolRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    Future<int> createCard(String nickname) {
      return creditCards.create(
        NewCreditCard(
          bank: 'HDFC',
          lastFourDigits: '5534',
          nickname: nickname,
          colorValue: 0xFF00695C,
          iconName: 'credit_card',
        ),
      );
    }

    test('links cards to a shared pool and clears individual limits', () async {
      final cardA = await createCard('HDFC A');
      final cardB = await createCard('HDFC B');
      await creditCards.updateCreditLimit(
        cardId: cardA,
        creditLimitPaise: 300000,
      );

      final poolId = await pools.create(
        const NewCreditLimitPool(
          name: 'HDFC shared',
          creditLimitPaise: 500000,
        ),
      );
      await pools.setCardsInPool(poolId: poolId, cardIds: {cardA, cardB});

      final linked = await pools.listCardsInPool(poolId);
      expect(linked.map((card) => card.id).toSet(), {cardA, cardB});
      expect(linked.every((card) => card.creditLimitPaise == null), isTrue);
      expect(
        linked.every((card) => card.creditLimitPoolId == poolId),
        isTrue,
      );
    });
  });
}
