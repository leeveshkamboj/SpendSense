import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/features/onboarding/data/onboarding_repository.dart';

void main() {
  test('resumes import from saved progress index', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = OnboardingRepository(database);

    expect(await repository.importLastIndex(), 0);
    await repository.saveImportProgress(lastIndex: 42, completed: false);
    expect(await repository.importLastIndex(), 42);
    expect(await repository.importCompleted(), isFalse);

    await repository.saveImportProgress(lastIndex: 100, completed: true);
    expect(await repository.importCompleted(), isTrue);

    await database.close();
  });
}
