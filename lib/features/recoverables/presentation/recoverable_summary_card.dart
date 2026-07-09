import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';

class RecoverableSummaryCard extends ConsumerWidget {
  const RecoverableSummaryCard({
    this.billingCycleId,
    super.key,
  });

  final int? billingCycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = billingCycleId == null
        ? ref.watch(recoverableSummaryProvider)
        : ref.watch(cycleRecoverableSummaryProvider(billingCycleId!));

    return summary.when(
      data: (rows) {
        if (rows.isEmpty) {
          return const Text('No outstanding recoverables');
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in rows.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(formatPaise(entry.value)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}

final cycleRecoverableSummaryProvider =
    FutureProvider.family<Map<String, int>, int>((ref, billingCycleId) {
  return ref
      .watch(recoverableRepositoryProvider)
      .summaryByPerson(billingCycleId: billingCycleId);
});
