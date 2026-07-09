import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spendsense/features/analytics/presentation/analytics_chart_type.dart';

class AnalyticsChart extends StatelessWidget {
  const AnalyticsChart({
    required this.chartType,
    required this.currentTotals,
    required this.previousTotals,
    super.key,
  });

  final AnalyticsChartType chartType;
  final Map<String, int> currentTotals;
  final Map<String, int> previousTotals;

  @override
  Widget build(BuildContext context) {
    if (currentTotals.isEmpty && previousTotals.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No data for this period')),
      );
    }

    return SizedBox(
      height: 240,
      child: switch (chartType) {
        AnalyticsChartType.pie => _PieChart(currentTotals: currentTotals),
        AnalyticsChartType.donut => _DonutChart(currentTotals: currentTotals),
        AnalyticsChartType.line => _LineChart(
            currentTotals: currentTotals,
            previousTotals: previousTotals,
          ),
        AnalyticsChartType.bar => _BarChart(
            currentTotals: currentTotals,
            previousTotals: previousTotals,
          ),
        AnalyticsChartType.stacked => _StackedChart(
            currentTotals: currentTotals,
            previousTotals: previousTotals,
          ),
        AnalyticsChartType.area => _AreaChart(
            currentTotals: currentTotals,
            previousTotals: previousTotals,
          ),
      },
    );
  }
}

class _PieChart extends StatelessWidget {
  const _PieChart({required this.currentTotals});

  final Map<String, int> currentTotals;

  @override
  Widget build(BuildContext context) {
    final sections = _sectionsFor(currentTotals, context);
    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 0,
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  const _DonutChart({required this.currentTotals});

  final Map<String, int> currentTotals;

  @override
  Widget build(BuildContext context) {
    final sections = _sectionsFor(currentTotals, context);
    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 48,
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.currentTotals,
    required this.previousTotals,
  });

  final Map<String, int> currentTotals;
  final Map<String, int> previousTotals;

  @override
  Widget build(BuildContext context) {
    final labels = _combinedLabels(currentTotals, previousTotals);
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: const FlGridData(show: true),
        titlesData: _bottomTitles(labels),
        lineBarsData: [
          _lineBar(
            color: Theme.of(context).colorScheme.primary,
            values: labels.map((label) => currentTotals[label]?.toDouble() ?? 0).toList(),
          ),
          _lineBar(
            color: Theme.of(context).colorScheme.secondary,
            values: labels.map((label) => previousTotals[label]?.toDouble() ?? 0).toList(),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart({
    required this.currentTotals,
    required this.previousTotals,
  });

  final Map<String, int> currentTotals;
  final Map<String, int> previousTotals;

  @override
  Widget build(BuildContext context) {
    final labels = _combinedLabels(currentTotals, previousTotals);
    return BarChart(
      BarChartData(
        minY: 0,
        gridData: const FlGridData(show: true),
        titlesData: _bottomTitles(labels),
        barGroups: [
          for (var i = 0; i < labels.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (currentTotals[labels[i]] ?? 0) / 100,
                  color: Theme.of(context).colorScheme.primary,
                  width: 8,
                ),
                BarChartRodData(
                  toY: (previousTotals[labels[i]] ?? 0) / 100,
                  color: Theme.of(context).colorScheme.secondary,
                  width: 8,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StackedChart extends StatelessWidget {
  const _StackedChart({
    required this.currentTotals,
    required this.previousTotals,
  });

  final Map<String, int> currentTotals;
  final Map<String, int> previousTotals;

  @override
  Widget build(BuildContext context) {
    final labels = _combinedLabels(currentTotals, previousTotals);
    return BarChart(
      BarChartData(
        minY: 0,
        gridData: const FlGridData(show: true),
        titlesData: _bottomTitles(labels),
        barGroups: [
          for (var i = 0; i < labels.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: ((previousTotals[labels[i]] ?? 0) +
                          (currentTotals[labels[i]] ?? 0)) /
                      100,
                  rodStackItems: [
                    BarChartRodStackItem(
                      0,
                      (previousTotals[labels[i]] ?? 0) / 100,
                      Theme.of(context).colorScheme.secondary,
                    ),
                    BarChartRodStackItem(
                      (previousTotals[labels[i]] ?? 0) / 100,
                      ((previousTotals[labels[i]] ?? 0) +
                              (currentTotals[labels[i]] ?? 0)) /
                          100,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ],
                  width: 16,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AreaChart extends StatelessWidget {
  const _AreaChart({
    required this.currentTotals,
    required this.previousTotals,
  });

  final Map<String, int> currentTotals;
  final Map<String, int> previousTotals;

  @override
  Widget build(BuildContext context) {
    final labels = _combinedLabels(currentTotals, previousTotals);
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: const FlGridData(show: true),
        titlesData: _bottomTitles(labels),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
            spots: [
              for (var i = 0; i < labels.length; i++)
                FlSpot(
                  i.toDouble(),
                  (currentTotals[labels[i]] ?? 0) / 100,
                ),
            ],
          ),
          LineChartBarData(
            isCurved: true,
            color: Theme.of(context).colorScheme.secondary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color:
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
            ),
            spots: [
              for (var i = 0; i < labels.length; i++)
                FlSpot(
                  i.toDouble(),
                  (previousTotals[labels[i]] ?? 0) / 100,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

List<PieChartSectionData> _sectionsFor(
  Map<String, int> totals,
  BuildContext context,
) {
  final colors = [
    Theme.of(context).colorScheme.primary,
    Theme.of(context).colorScheme.secondary,
    Theme.of(context).colorScheme.tertiary,
    Colors.orange,
    Colors.teal,
    Colors.purple,
  ];
  final entries = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return [
    for (var i = 0; i < entries.length; i++)
      PieChartSectionData(
        value: entries[i].value.toDouble(),
        title: entries[i].key,
        color: colors[i % colors.length],
        radius: 56,
        titleStyle: Theme.of(context).textTheme.labelSmall,
      ),
  ];
}

List<String> _combinedLabels(
  Map<String, int> currentTotals,
  Map<String, int> previousTotals,
) {
  final labels = <String>{
    ...currentTotals.keys,
    ...previousTotals.keys,
  }.toList()
    ..sort();
  return labels.take(6).toList();
}

FlTitlesData _bottomTitles(List<String> labels) {
  return FlTitlesData(
    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: labels.isNotEmpty,
        getTitlesWidget: (value, meta) {
          final index = value.toInt();
          if (index < 0 || index >= labels.length) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              labels[index],
              style: const TextStyle(fontSize: 10),
            ),
          );
        },
      ),
    ),
  );
}

LineChartBarData _lineBar({
  required Color color,
  required List<double> values,
}) {
  return LineChartBarData(
    isCurved: true,
    color: color,
    barWidth: 2,
    dotData: const FlDotData(show: true),
    spots: [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i] / 100),
    ],
  );
}
