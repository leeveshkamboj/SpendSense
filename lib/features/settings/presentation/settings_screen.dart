import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/budgets/presentation/budget_settings_screen.dart';
import 'package:spendsense/features/recoverables/presentation/recoverables_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryBudgets = ref.watch(categoryBudgetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Recoverables'),
            subtitle: const Text('Outstanding amounts by person'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/accounts/recoverables'),
          ),
          ListTile(
            title: const Text('Budgets'),
            subtitle: const Text('Monthly and category limits'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BudgetSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          categoryBudgets.when(
            data: (rows) {
              if (rows.isEmpty) {
                return const ListTile(
                  title: Text('No category budgets configured'),
                );
              }

              return Column(
                children: [
                  for (final row in rows)
                    ListTile(
                      title: Text(row.category),
                      trailing: Text('₹${row.limitPaise / 100}'),
                    ),
                ],
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => ListTile(title: Text('Error: $error')),
          ),
        ],
      ),
    );
  }
}
