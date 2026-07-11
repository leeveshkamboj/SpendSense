import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/accounts/presentation/bank_account_detail_screen.dart';
import 'package:spendsense/features/analytics/analytics_screen.dart';
import 'package:spendsense/features/bills/bills_screen.dart';
import 'package:spendsense/features/billing_cycles/presentation/billing_cycle_detail_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_configure_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_detail_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_setup_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/shared_credit_limit_form_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/shared_credit_limits_screen.dart';
import 'package:spendsense/features/dashboard/dashboard_screen.dart';
import 'package:spendsense/features/merchants/presentation/merchants_screen.dart';
import 'package:spendsense/features/recoverables/presentation/recoverables_screen.dart';
import 'package:spendsense/features/backup/presentation/backup_settings_screen.dart';
import 'package:spendsense/features/reports/presentation/report_export_screen.dart';
import 'package:spendsense/features/settings/presentation/alert_thresholds_settings_screen.dart';
import 'package:spendsense/features/settings/presentation/app_lock_settings_screen.dart';
import 'package:spendsense/features/settings/presentation/archive_settings_screen.dart';
import 'package:spendsense/features/settings/presentation/budget_settings_route_screen.dart';
import 'package:spendsense/features/settings/presentation/sms_reimport_screen.dart';
import 'package:spendsense/features/settings/presentation/theme_settings_screen.dart';
import 'package:spendsense/features/settings/settings_screen.dart';
import 'package:spendsense/features/shell/app_shell.dart';
import 'package:spendsense/features/transactions/presentation/copy_transaction_screen.dart';
import 'package:spendsense/features/transactions/presentation/cycle_move_screen.dart';
import 'package:spendsense/features/transactions/presentation/edit_transaction_screen.dart';
import 'package:spendsense/features/transactions/presentation/manual_card_transaction_screen.dart';
import 'package:spendsense/features/transactions/presentation/merge_transaction_screen.dart';
import 'package:spendsense/features/transactions/presentation/split_transaction_screen.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:spendsense/features/transactions/transactions_screen.dart';

const dashboardLocation = '/dashboard';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: dashboardLocation,
    redirect: (context, state) {
      final path = state.uri.path;
      if (path.isEmpty || path == '/') {
        return dashboardLocation;
      }
      return null;
    },
    errorBuilder: (context, state) => const _UnknownRouteScreen(),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboardLocation,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsScreen(),
                routes: [
                  GoRoute(
                    path: 'manual',
                    builder: (context, state) => ManualCardTransactionScreen(
                      initialKind: state.uri.queryParameters['kind'],
                    ),
                  ),
                  GoRoute(
                    path: 'copy/:id',
                    builder: (context, state) => CopyTransactionScreen(
                      sourceTransactionId:
                          int.parse(state.pathParameters['id']!),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => TransactionDetailScreen(
                      transactionId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) => EditTransactionScreen(
                          transactionId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                      GoRoute(
                        path: 'split',
                        builder: (context, state) => SplitTransactionScreen(
                          transactionId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                      GoRoute(
                        path: 'merge',
                        builder: (context, state) => MergeTransactionScreen(
                          survivorTransactionId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                      GoRoute(
                        path: 'cycle-move',
                        builder: (context, state) => CycleMoveScreen(
                          transactionId:
                              int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                builder: (context, state) => const AccountsScreen(),
                routes: [
                  GoRoute(
                    path: 'recoverables',
                    builder: (context, state) => const RecoverablesScreen(),
                  ),
                  GoRoute(
                    path: 'shared-limits',
                    builder: (context, state) =>
                        const SharedCreditLimitsScreen(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        builder: (context, state) =>
                            const SharedCreditLimitFormScreen(),
                      ),
                      GoRoute(
                        path: ':poolId',
                        builder: (context, state) => SharedCreditLimitFormScreen(
                          poolId: int.parse(state.pathParameters['poolId']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'cards/new',
                    builder: (context, state) => const CreditCardSetupScreen(),
                  ),
                  GoRoute(
                    path: 'cards/:id',
                    builder: (context, state) => CreditCardDetailScreen(
                      cardId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'configure',
                        builder: (context, state) => CreditCardConfigureScreen(
                          cardId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                      GoRoute(
                        path: 'cycles/:cycleId',
                        builder: (context, state) => BillingCycleDetailScreen(
                          cardId: int.parse(state.pathParameters['id']!),
                          cycleId: int.parse(state.pathParameters['cycleId']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'bank/:id',
                    builder: (context, state) => BankAccountDetailScreen(
                      accountId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bills',
                builder: (context, state) => const BillsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'recoverables',
            builder: (context, state) => const RecoverablesScreen(),
          ),
          GoRoute(
            path: 'merchants',
            builder: (context, state) => const MerchantsScreen(),
          ),
          GoRoute(
            path: 'backup',
            builder: (context, state) => const BackupSettingsScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportExportScreen(),
          ),
          GoRoute(
            path: 'app-lock',
            builder: (context, state) => const AppLockSettingsScreen(),
          ),
          GoRoute(
            path: 'archive',
            builder: (context, state) => const ArchiveSettingsScreen(),
          ),
          GoRoute(
            path: 'budgets',
            builder: (context, state) => const BudgetSettingsRouteScreen(),
          ),
          GoRoute(
            path: 'alert-thresholds',
            builder: (context, state) =>
                const AlertThresholdsSettingsScreen(),
          ),
          GoRoute(
            path: 'theme',
            builder: (context, state) => const ThemeSettingsScreen(),
          ),
          GoRoute(
            path: 'sms-reimport',
            builder: (context, state) => const SmsReimportScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Shown briefly for unknown routes, then sends the user to the dashboard.
class _UnknownRouteScreen extends StatefulWidget {
  const _UnknownRouteScreen();

  @override
  State<_UnknownRouteScreen> createState() => _UnknownRouteScreenState();
}

class _UnknownRouteScreenState extends State<_UnknownRouteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.go(dashboardLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
