class QuickAddWidgetLaunch {
  static const expenseUri = 'spendsense://quick-add/expense';
  static const incomeUri = 'spendsense://quick-add/income';

  static String? routeFor(Uri uri) {
    if (uri.scheme != 'spendsense' || uri.host != 'quick-add') {
      return null;
    }

    return switch (uri.pathSegments.firstOrNull) {
      'expense' => '/transactions/manual?kind=expense',
      'income' => '/transactions/manual?kind=refund',
      _ => null,
    };
  }
}
