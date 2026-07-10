import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/core/formatting/amount_display.dart';
import 'package:spendsense/features/credit_cards/data/credit_limit_pool_providers.dart';

class SharedCreditLimitsScreen extends ConsumerWidget {
  const SharedCreditLimitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pools = ref.watch(creditLimitPoolsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shared credit limits')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/shared-limits/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add pool'),
      ),
      body: pools.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Link cards that share one bank credit line, such as two '
                  'HDFC cards on a single limit.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final pool = items[index];
              return Card(
                child: ListTile(
                  title: Text(pool.name),
                  subtitle: Text(formatPaise(pool.creditLimitPaise)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/accounts/shared-limits/${pool.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
