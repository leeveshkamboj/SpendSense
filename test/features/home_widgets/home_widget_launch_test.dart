import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/home_widgets/domain/home_widget_launch.dart';

void main() {
  group('HomeWidgetLaunch', () {
    test('maps quick add widget clicks to manual entry routes', () {
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse(HomeWidgetLaunch.expenseUri)),
        '/transactions/manual?kind=expense',
      );
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse(HomeWidgetLaunch.incomeUri)),
        '/transactions/manual?kind=refund',
      );
    });

    test('maps summary and budget widgets to dashboard or budget setup', () {
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse('spendsense://widget/dashboard')),
        '/dashboard',
      );
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse('spendsense://widget/budget')),
        '/dashboard',
      );
      expect(
        HomeWidgetLaunch.routeFor(
          Uri.parse('spendsense://widget/budget?setup=1'),
        ),
        '/settings/budgets',
      );
    });

    test('maps list widgets to their primary screens', () {
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse('spendsense://widget/accounts')),
        '/accounts',
      );
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse('spendsense://widget/transactions')),
        '/transactions',
      );
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse('spendsense://widget/bills')),
        '/bills',
      );
    });

    test('maps row widgets to detail routes', () {
      expect(
        HomeWidgetLaunch.routeFor(
          Uri.parse('spendsense://widget/transaction/42'),
        ),
        '/transactions/42',
      );
      expect(
        HomeWidgetLaunch.routeFor(Uri.parse('spendsense://widget/card/7')),
        '/accounts/cards/7',
      );
      expect(
        HomeWidgetLaunch.routeFor(
          Uri.parse('spendsense://widget/bill?card_id=3&cycle_id=9'),
        ),
        '/accounts/cards/3/cycles/9',
      );
    });
  });
}
