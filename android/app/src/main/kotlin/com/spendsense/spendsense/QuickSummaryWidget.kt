package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
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

        for (widgetId in appWidgetIds) {
            WidgetUpdateUtils.updateSafely(
                context,
                appWidgetManager,
                widgetId,
                R.layout.quick_summary_widget,
            ) { views ->
                WidgetThemeUtils.applyBaseTheme(context, views, R.id.widget_root)
                WidgetThemeUtils.setHeroAmount(
                    context,
                    views,
                    R.id.spent_text,
                    WidgetFormatUtils.formatPaise(spent),
                )
                WidgetThemeUtils.setBody(
                    context,
                    views,
                    R.id.spent_label,
                    "Personal spend · excludes recoverables",
                )

                if (limit.isEmpty()) {
                    views.setViewVisibility(R.id.budget_progress, View.GONE)
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.remaining_text,
                        "Set a monthly budget",
                    )
                } else {
                    views.setViewVisibility(R.id.budget_progress, View.VISIBLE)
                    val spentValue = spent.toLongOrNull() ?: 0L
                    val limitValue = limit.toLongOrNull() ?: 1L
                    val progress = ((spentValue * 100) / limitValue).toInt().coerceIn(0, 100)
                    views.setProgressBar(R.id.budget_progress, 100, progress, false)
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.remaining_text,
                        "${WidgetFormatUtils.formatPaise(remaining)} remaining of ${WidgetFormatUtils.formatPaise(limit)}",
                    )
                }

                val launchUri = if (limit.isEmpty()) {
                    "spendsense://widget/budget?setup=1"
                } else {
                    "spendsense://widget/dashboard"
                }
                WidgetLaunchUtils.bindLaunch(context, views, R.id.widget_root, launchUri)
            }
        }
    }
}
