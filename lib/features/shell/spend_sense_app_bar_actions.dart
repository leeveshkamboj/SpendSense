import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

List<Widget> spendSenseAppBarActions(BuildContext context) {
  return [
    IconButton(
      onPressed: () => context.push('/settings'),
      tooltip: 'Settings',
      icon: const Icon(Icons.settings_outlined),
    ),
  ];
}
