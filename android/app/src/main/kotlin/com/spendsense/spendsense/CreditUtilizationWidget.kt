package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
import es.antonborri.home_widget.HomeWidgetProvider

class CreditUtilizationWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val spent = widgetData.getString("credit_utilization_spent", "0") ?: "0"
        val limit = widgetData.getString("credit_utilization_limit", "") ?: ""
        val needsLimit = widgetData.getString("credit_utilization_needs_limit", "false") == "true"
        val cardsJson = widgetData.getString("credit_utilization_cards_json", "[]") ?: "[]"

        for (widgetId in appWidgetIds) {
            WidgetUpdateUtils.updateSafely(
                context,
                appWidgetManager,
                widgetId,
                R.layout.credit_utilization_widget,
            ) { views ->
                WidgetThemeUtils.applyBaseTheme(context, views, R.id.widget_root)
                WidgetThemeUtils.setTitle(
                    context,
                    views,
                    R.id.widget_title,
                    "Credit Utilization",
                )
                WidgetThemeUtils.setAmount(
                    context,
                    views,
                    R.id.spent_text,
                    WidgetFormatUtils.formatPaise(spent),
                )

                if (needsLimit || limit.isEmpty()) {
                    views.setViewVisibility(R.id.utilization_progress, View.GONE)
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.limit_text,
                        "Set credit limits on your cards",
                    )
                } else {
                    views.setViewVisibility(R.id.utilization_progress, View.VISIBLE)
                    val spentValue = spent.toLongOrNull() ?: 0L
                    val limitValue = limit.toLongOrNull() ?: 1L
                    val progress = ((spentValue * 100) / limitValue).toInt().coerceIn(0, 100)
                    views.setProgressBar(R.id.utilization_progress, 100, progress, false)
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.limit_text,
                        "${WidgetFormatUtils.formatPaise(spent)} of ${WidgetFormatUtils.formatPaise(limit)} used",
                    )
                }

                WidgetChartUtils.bindUtilizationRows(
                    views,
                    cardsJson,
                    listOf(
                        Triple(R.id.card_row_1, R.id.card_row_1_color, R.id.card_row_1_progress),
                        Triple(R.id.card_row_2, R.id.card_row_2_color, R.id.card_row_2_progress),
                        Triple(R.id.card_row_3, R.id.card_row_3_color, R.id.card_row_3_progress),
                    ),
                )
            }
        }
    }
}
