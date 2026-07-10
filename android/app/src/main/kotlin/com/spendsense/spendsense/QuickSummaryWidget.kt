package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import es.antonborri.home_widget.HomeWidgetProvider

class QuickSummaryWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val spent = widgetData.getString("quick_summary_spent", "0") ?: "0"
        val remaining = widgetData.getString("quick_summary_remaining", "") ?: ""
        val limit = widgetData.getString("quick_summary_budget_limit", "") ?: ""
        val chartJson = widgetData.getString("quick_summary_card_chart_json", "[]") ?: "[]"

        for (widgetId in appWidgetIds) {
            WidgetUpdateUtils.updateSafely(
                context,
                appWidgetManager,
                widgetId,
                R.layout.quick_summary_widget,
            ) { views ->
                views.setTextViewText(R.id.spent_text, WidgetFormatUtils.formatPaise(spent))
                views.setTextViewText(
                    R.id.remaining_text,
                    if (limit.isEmpty()) {
                        "Set a monthly budget"
                    } else {
                        "${WidgetFormatUtils.formatPaise(remaining)} remaining"
                    },
                )
                WidgetChartUtils.bindStackedSpendChart(
                    views,
                    chartJson,
                    R.id.card_spend_chart,
                    listOf(
                        R.id.chart_segment_1,
                        R.id.chart_segment_2,
                        R.id.chart_segment_3,
                        R.id.chart_segment_4,
                    ),
                )
            }
        }
    }
}
