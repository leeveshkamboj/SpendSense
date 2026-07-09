package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class BudgetWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val spent = widgetData.getString("budget_spent", "0") ?: "0"
        val limit = widgetData.getString("budget_limit", "") ?: ""
        val remaining = widgetData.getString("budget_remaining", "") ?: ""
        val daily = widgetData.getString("budget_daily", "") ?: ""
        val needsPrompt = widgetData.getString("budget_needs_prompt", "false") == "true"
        val chartJson = widgetData.getString("budget_card_chart_json", "[]") ?: "[]"

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.budget_widget)
            views.setTextViewText(R.id.spent_text, WidgetFormatUtils.formatPaise(spent))

            if (needsPrompt || limit.isEmpty()) {
                views.setViewVisibility(R.id.budget_progress, View.GONE)
                views.setViewVisibility(R.id.card_spend_chart, View.GONE)
                views.setTextViewText(R.id.daily_text, "Set a monthly budget")
                views.setTextViewText(R.id.remaining_text, "")
            } else {
                views.setViewVisibility(R.id.budget_progress, View.VISIBLE)
                val spentValue = spent.toLongOrNull() ?: 0L
                val limitValue = limit.toLongOrNull() ?: 1L
                val progress = ((spentValue * 100) / limitValue).toInt().coerceIn(0, 100)
                views.setProgressBar(R.id.budget_progress, 100, progress, false)
                views.setTextViewText(
                    R.id.daily_text,
                    "${WidgetFormatUtils.formatPaise(daily)} left for today",
                )
                views.setTextViewText(
                    R.id.remaining_text,
                    "${WidgetFormatUtils.formatPaise(remaining)} remaining this cycle",
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

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
