import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_summary.dart';
import 'package:spendsense/features/recoverables/data/recoverable_providers.dart';

class RecoverableSummaryCard extends ConsumerWidget {
  const RecoverableSummaryCard({
    this.billingCycleId,
    this.embedded = false,
    super.key,
  });

  final int? billingCycleId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = billingCycleId == null
        ? ref.watch(recoverableSummaryProvider)
        : ref.watch(cycleRecoverableSummaryProvider(billingCycleId!));

    return summary.when(
      data: (rows) {
        if (rows.isEmpty) {
          final message = 'No outstanding recoverables';
          if (embedded) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            );
          }
          return Text(message);
        }

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in rows.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(
                      formatPaise(entry.value),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
          ],
        );

        if (embedded) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        );
      },
      loading: () => embedded
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            )
          : const LinearProgressIndicator(),
      error: (error, _) => embedded
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $error'),
            )
          : Text('Error: $error'),
    );
  }
}

final cycleRecoverableSummaryProvider =
    FutureProvider.family<Map<String, int>, int>((ref, billingCycleId) {
  return ref
      .watch(recoverableRepositoryProvider)
      .summaryByPerson(billingCycleId: billingCycleId);
});
