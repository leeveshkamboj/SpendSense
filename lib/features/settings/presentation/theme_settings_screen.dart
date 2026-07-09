import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendsense/features/settings/data/app_preferences_providers.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: themeMode.when(
        data: (selected) => Column(
          children: [
            for (final mode in const ['system', 'light', 'dark'])
              RadioListTile<String>(
                title: Text(_label(mode)),
                value: mode,
                groupValue: selected,
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  await ref
                      .read(appPreferencesRepositoryProvider)
                      .setThemeMode(value);
                  ref.invalidate(themeModeProvider);
                },
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  String _label(String mode) {
    return switch (mode) {
      'light' => 'Light',
      'dark' => 'Dark',
      _ => 'System default',
    };
  }
}
