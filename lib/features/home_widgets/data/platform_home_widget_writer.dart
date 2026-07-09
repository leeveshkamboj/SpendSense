import 'package:home_widget/home_widget.dart';
import 'package:spendsense/features/home_widgets/data/home_widget_writer.dart';

class PlatformHomeWidgetWriter implements HomeWidgetWriter {
  @override
  Future<void> saveValue(String key, String value) {
    return HomeWidget.saveWidgetData<String>(key, value);
  }

  @override
  Future<void> updateAllWidgets() async {
    const widgets = [
      'com.spendsense.spendsense.QuickSummaryWidget',
      'com.spendsense.spendsense.CreditUtilizationWidget',
      'com.spendsense.spendsense.RecentTransactionsWidget',
      'com.spendsense.spendsense.BillsWidget',
      'com.spendsense.spendsense.BudgetWidget',
      'com.spendsense.spendsense.QuickAddWidget',
    ];
    for (final name in widgets) {
      await HomeWidget.updateWidget(qualifiedAndroidName: name);
    }
  }
}
