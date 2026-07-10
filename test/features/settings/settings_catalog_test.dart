import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/settings/domain/settings_catalog.dart';
import 'package:spendsense/features/settings/domain/settings_entry.dart';

void main() {
  group('Settings catalog', () {
    test('groups entries by section', () {
      final entries = [
        SettingsEntry(
          group: SettingsGroup.security,
          title: 'App lock',
          subtitle: 'PIN',
          keywords: const [],
        ),
        SettingsEntry(
          group: SettingsGroup.data,
          title: 'Backup',
          subtitle: 'Restore',
          keywords: const [],
        ),
      ];

      final grouped = groupSettingsEntries(entries);

      expect(grouped[SettingsGroup.security], hasLength(1));
      expect(grouped[SettingsGroup.data], hasLength(1));
    });

    test('filters entries by search query', () {
      final entries = [
        SettingsEntry(
          group: SettingsGroup.data,
          title: 'Backup & Restore',
          subtitle: 'Encrypted export',
          keywords: const ['backup'],
        ),
        SettingsEntry(
          group: SettingsGroup.data,
          title: 'Merchants',
          subtitle: 'Categories',
          keywords: const ['merchant'],
        ),
      ];

      final filtered = filterSettingsEntries(entries, query: 'backup');

      expect(filtered, hasLength(1));
      expect(filtered.single.title, 'Backup & Restore');
    });
  });
}
