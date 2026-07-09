enum AnalyticsChartType {
  pie,
  donut,
  line,
  bar,
  stacked,
  area,
}

extension AnalyticsChartTypeLabel on AnalyticsChartType {
  String get label => switch (this) {
        AnalyticsChartType.pie => 'Pie',
        AnalyticsChartType.donut => 'Donut',
        AnalyticsChartType.line => 'Line',
        AnalyticsChartType.bar => 'Bar',
        AnalyticsChartType.stacked => 'Stacked',
        AnalyticsChartType.area => 'Area',
      };
}

enum AnalyticsBreakdown {
  category,
  merchant,
  card,
  tag,
}

extension AnalyticsBreakdownLabel on AnalyticsBreakdown {
  String get label => switch (this) {
        AnalyticsBreakdown.category => 'Category',
        AnalyticsBreakdown.merchant => 'Merchant',
        AnalyticsBreakdown.card => 'Card',
        AnalyticsBreakdown.tag => 'Tag',
      };
}
