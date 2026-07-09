import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendsense/features/accounts/presentation/accounts_screen.dart';
import 'package:spendsense/features/analytics/analytics_screen.dart';
import 'package:spendsense/features/bills/bills_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_detail_screen.dart';
import 'package:spendsense/features/credit_cards/presentation/credit_card_setup_screen.dart';
import 'package:spendsense/features/dashboard/dashboard_screen.dart';
import 'package:spendsense/features/recoverables/presentation/recoverables_screen.dart';
import 'package:spendsense/features/settings/settings_screen.dart';
import 'package:spendsense/features/shell/app_shell.dart';
import 'package:spendsense/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:spendsense/features/transactions/transactions_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
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
                    path: ':id',
                    builder: (context, state) => TransactionDetailScreen(
                      transactionId: int.parse(state.pathParameters['id']!),
                    ),
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
                    ],
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
