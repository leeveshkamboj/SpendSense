import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/settings/data/app_data_providers.dart';
import 'package:spendsense/features/settings/presentation/delete_all_data_dialog.dart';
import 'package:spendsense/features/budgets/data/budget_providers.dart';
import 'package:spendsense/features/budgets/presentation/budget_settings_screen.dart';

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
            title: const Text('Merchants'),
            subtitle: const Text('Display names, categories, and tags'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/merchants'),
          ),
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
          ListTile(
            title: const Text('Export report'),
            subtitle: const Text('PDF, CSV, or Excel summary'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/reports'),
          ),
          ListTile(
            title: const Text('Backup & Restore'),
            subtitle: const Text('Encrypted .ssb export and restore'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/backup'),
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
          const Divider(),
          Text(
            'Danger zone',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          ListTile(
            title: Text(
              'Delete all data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Permanently remove all local SpendSense data'),
            onTap: () => _confirmDeleteAllData(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAllData(BuildContext context, WidgetRef ref) async {
    final choice = await showDeleteAllDataDialog(context);
    if (!context.mounted || choice == null || choice == DeleteAllChoice.cancel) {
      return;
    }

    if (choice == DeleteAllChoice.backupFirst) {
      await openBackupSettings(context);
      return;
    }

    final confirmed = await confirmDeleteAllAnyway(context);
    if (!context.mounted || !confirmed) {
      return;
    }

    await ref.read(appDataRepositoryProvider).deleteAllData();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data deleted')),
    );
  }
}
