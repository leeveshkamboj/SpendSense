import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/database/database.dart';
import 'package:spendsense/core/database/database_provider.dart';
import 'package:spendsense/features/sms_capture/data/sms_sender_repository.dart';

final smsSenderRepositoryProvider = Provider<SmsSenderRepository>((ref) {
  return SmsSenderRepository(ref.watch(databaseProvider));
});

final smsSendersProvider = FutureProvider<List<SmsSender>>((ref) async {
  final repository = ref.watch(smsSenderRepositoryProvider);
  await repository.ensureBuiltInSenders();
  return repository.listAll();
});
