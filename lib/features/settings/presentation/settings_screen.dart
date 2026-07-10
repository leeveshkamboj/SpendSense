import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/core/branding/app_logo.dart';
import 'package:spendsense/features/settings/data/app_data_providers.dart';
import 'package:spendsense/features/settings/domain/settings_catalog.dart';
import 'package:spendsense/features/settings/domain/settings_entry.dart';
import 'package:spendsense/features/settings/presentation/delete_all_data_dialog.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final catalog = buildSettingsCatalog(context);
    final filtered = filterSettingsEntries(catalog, query: _query);
    final grouped = groupSettingsEntries(filtered);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Center(child: AppBrandHeader(logoSize: 72)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SearchBar(
              hintText: 'Search settings',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          for (final group in SettingsGroup.values) ...[
            if (grouped[group]?.isNotEmpty ?? false) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  group.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              for (final entry in grouped[group]!)
                ListTile(
                  title: Text(entry.title),
                  subtitle: Text(entry.subtitle),
                  trailing: entry.onTap == null
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: entry.onTap,
                ),
            ],
          ],
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Danger zone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
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
