import 'package:flutter_test/flutter_test.dart';
import 'package:spendsense/features/home_widgets/domain/quick_add_widget_launch.dart';

void main() {
  group('QuickAddWidgetLaunch', () {
    test('maps expense widget click to manual entry route', () {
      expect(
        QuickAddWidgetLaunch.routeFor(Uri.parse(QuickAddWidgetLaunch.expenseUri)),
        '/transactions/manual?kind=expense',
      );
    });

    test('maps income widget click to manual refund entry route', () {
      expect(
        QuickAddWidgetLaunch.routeFor(Uri.parse(QuickAddWidgetLaunch.incomeUri)),
        '/transactions/manual?kind=refund',
      );
    });
  });
}
