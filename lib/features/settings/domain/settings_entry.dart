import 'package:flutter/material.dart';

enum SettingsGroup {
  security('Security'),
  data('Data'),
  capture('Capture'),
  budgets('Budgets'),
  appearance('Appearance'),
  about('About');

  const SettingsGroup(this.label);

  final String label;
}

class SettingsEntry {
  const SettingsEntry({
    required this.group,
    required this.title,
    required this.subtitle,
    required this.keywords,
    this.onTap,
    this.isDanger = false,
    this.builder,
  });

  final SettingsGroup group;
  final String title;
  final String subtitle;
  final List<String> keywords;
  final VoidCallback? onTap;
  final bool isDanger;
  final WidgetBuilder? builder;

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) {
      return true;
    }

    final normalized = query.trim().toLowerCase();
    final haystack = [
      title,
      subtitle,
      group.label,
      ...keywords,
    ].join(' ').toLowerCase();

    return haystack.contains(normalized);
  }
}
