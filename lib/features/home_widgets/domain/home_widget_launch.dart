class HomeWidgetLaunch {
  static const expenseUri = 'spendsense://quick-add/expense';
  static const incomeUri = 'spendsense://quick-add/income';

  static String? routeFor(Uri uri) {
    if (uri.scheme != 'spendsense') {
      return null;
    }

    return switch (uri.host) {
      'quick-add' => _quickAddRoute(uri),
      'widget' => _widgetRoute(uri),
      _ => null,
    };
  }

  static String? _quickAddRoute(Uri uri) {
    return switch (uri.pathSegments.firstOrNull) {
      'expense' => '/transactions/manual?kind=expense',
      'income' => '/transactions/manual?kind=refund',
      _ => null,
    };
  }

  static String? _widgetRoute(Uri uri) {
    if (uri.pathSegments.isEmpty) {
      return null;
    }

    return switch (uri.pathSegments.first) {
      'dashboard' => '/dashboard',
      'budget' => uri.queryParameters['setup'] == '1'
          ? '/settings/budgets'
          : '/dashboard',
      'accounts' => '/accounts',
      'transactions' => '/transactions',
      'transaction' => _transactionRoute(uri),
      'bills' => '/bills',
      'bill' => _billRoute(uri),
      'card' => _cardRoute(uri),
      _ => null,
    };
  }

  static String? _transactionRoute(Uri uri) {
    final id = uri.pathSegments.elementAtOrNull(1);
    if (id == null || int.tryParse(id) == null) {
      return '/transactions';
    }
    return '/transactions/$id';
  }

  static String? _cardRoute(Uri uri) {
    final id = uri.pathSegments.elementAtOrNull(1);
    if (id == null || int.tryParse(id) == null) {
      return '/accounts';
    }
    return '/accounts/cards/$id';
  }

  static String? _billRoute(Uri uri) {
    final cardId = uri.queryParameters['card_id'];
    final cycleId = uri.queryParameters['cycle_id'];
    if (cardId == null ||
        cycleId == null ||
        int.tryParse(cardId) == null ||
        int.tryParse(cycleId) == null) {
      return '/bills';
    }
    return '/accounts/cards/$cardId/cycles/$cycleId';
  }
}
