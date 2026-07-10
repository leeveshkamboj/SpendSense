package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
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

        for (widgetId in appWidgetIds) {
            WidgetUpdateUtils.updateSafely(
                context,
                appWidgetManager,
                widgetId,
                R.layout.budget_widget,
            ) { views ->
                WidgetThemeUtils.applyBaseTheme(context, views, R.id.widget_root)
                WidgetThemeUtils.setHeroAmount(
                    context,
                    views,
                    R.id.spent_text,
                    WidgetFormatUtils.formatPaise(spent),
                )

                if (needsPrompt || limit.isEmpty()) {
                    views.setViewVisibility(R.id.budget_progress, View.GONE)
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.daily_text,
                        "Set a monthly budget",
                    )
                    views.setTextViewText(R.id.remaining_text, "")
                } else {
                    views.setViewVisibility(R.id.budget_progress, View.VISIBLE)
                    val spentValue = spent.toLongOrNull() ?: 0L
                    val limitValue = limit.toLongOrNull() ?: 1L
                    val progress = ((spentValue * 100) / limitValue).toInt().coerceIn(0, 100)
                    views.setProgressBar(R.id.budget_progress, 100, progress, false)
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.daily_text,
                        "${WidgetFormatUtils.formatPaise(daily)} left for today",
                    )
                    WidgetThemeUtils.setBody(
                        context,
                        views,
                        R.id.remaining_text,
                        "${WidgetFormatUtils.formatPaise(remaining)} remaining this cycle",
                    )
                }

                val launchUri = if (needsPrompt || limit.isEmpty()) {
                    "spendsense://widget/budget?setup=1"
                } else {
                    "spendsense://widget/budget"
                }
                WidgetLaunchUtils.bindLaunch(context, views, R.id.widget_root, launchUri)
            }
        }
    }
}
