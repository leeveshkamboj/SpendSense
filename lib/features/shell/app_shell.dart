import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/backup/data/backup_providers.dart';
import 'package:spendsense/features/bills/presentation/notification_permission_banner.dart';
import 'package:spendsense/features/budgets/data/spending_alert_providers.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_providers.dart';
import 'package:spendsense/features/sms_capture/presentation/sms_permission_banner.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(spendingAlertSyncProvider);
    ref.watch(homeWidgetSyncProvider);
    ref.watch(autoBackupSyncProvider);
    final showFab = navigationShell.currentIndex != 5;

    return Scaffold(
      body: Column(
        children: [
          const SmsPermissionBanner(),
          const NotificationPermissionBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Accounts',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.request_page_outlined),
            selectedIcon: Icon(Icons.request_page),
            label: 'Bills',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => showQuickAddSheet(context),
              tooltip: 'Quick Add',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

void showQuickAddSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('Expense'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/transactions/manual?kind=expense');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Income'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.push('/transactions/manual?kind=refund');
              },
            ),
          ],
        ),
      );
    },
  );
}
