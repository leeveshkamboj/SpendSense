import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/settings/domain/settings_entry.dart';

List<SettingsEntry> buildSettingsCatalog(BuildContext context) {
  return [
    SettingsEntry(
      group: SettingsGroup.security,
      title: 'App lock',
      subtitle: 'PIN and biometric protection',
      keywords: ['pin', 'biometric', 'security'],
      onTap: () => context.push('/settings/app-lock'),
    ),
    SettingsEntry(
      group: SettingsGroup.data,
      title: 'Merchants',
      subtitle: 'Display names, categories, and tags',
      keywords: ['merchant', 'category', 'tag'],
      onTap: () => context.push('/settings/merchants'),
    ),
    SettingsEntry(
      group: SettingsGroup.data,
      title: 'Recoverables',
      subtitle: 'Outstanding amounts by person',
      keywords: ['recoverable', 'person', 'owe'],
      onTap: () => context.push('/settings/recoverables'),
    ),
    SettingsEntry(
      group: SettingsGroup.data,
      title: 'Archive',
      subtitle: 'Archived cards and bank accounts',
      keywords: ['archive', 'hidden', 'restore'],
      onTap: () => context.push('/settings/archive'),
    ),
    SettingsEntry(
      group: SettingsGroup.data,
      title: 'Re-import SMS',
      subtitle: 'Scan inbox again for missed transactions',
      keywords: ['sms', 'import', 'inbox', 'reimport'],
      onTap: () => context.push('/settings/sms-reimport'),
    ),
    SettingsEntry(
      group: SettingsGroup.data,
      title: 'Export report',
      subtitle: 'PDF, CSV, or Excel summary',
      keywords: ['export', 'report', 'pdf', 'csv', 'excel'],
      onTap: () => context.push('/settings/reports'),
    ),
    SettingsEntry(
      group: SettingsGroup.data,
      title: 'Backup & Restore',
      subtitle: 'Encrypted .ssb export and restore',
      keywords: ['backup', 'restore', 'ssb'],
      onTap: () => context.push('/settings/backup'),
    ),
    SettingsEntry(
      group: SettingsGroup.budgets,
      title: 'Budgets',
      subtitle: 'Monthly and category limits',
      keywords: ['budget', 'limit', 'monthly', 'category'],
      onTap: () => context.push('/settings/budgets'),
    ),
    SettingsEntry(
      group: SettingsGroup.budgets,
      title: 'Spending alerts',
      subtitle: 'Budget alert thresholds',
      keywords: ['alert', 'threshold', 'spending', 'notification'],
      onTap: () => context.push('/settings/alert-thresholds'),
    ),
    SettingsEntry(
      group: SettingsGroup.appearance,
      title: 'Theme',
      subtitle: 'Light, dark, or follow system',
      keywords: ['theme', 'dark', 'light', 'appearance'],
      onTap: () => context.push('/settings/theme'),
    ),
    SettingsEntry(
      group: SettingsGroup.about,
      title: 'About SpendSense',
      subtitle: 'Version 1.0.0',
      keywords: ['about', 'version'],
    ),
  ];
}

List<SettingsEntry> filterSettingsEntries(
  List<SettingsEntry> entries, {
  required String query,
}) {
  return entries.where((entry) => entry.matchesQuery(query)).toList();
}

Map<SettingsGroup, List<SettingsEntry>> groupSettingsEntries(
  List<SettingsEntry> entries,
) {
  final grouped = <SettingsGroup, List<SettingsEntry>>{};
  for (final entry in entries) {
    grouped.putIfAbsent(entry.group, () => []).add(entry);
  }
  return grouped;
}
