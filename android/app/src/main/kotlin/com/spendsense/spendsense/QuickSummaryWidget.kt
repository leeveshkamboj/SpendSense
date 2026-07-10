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

        val budgetPill = PillMeterIds(
            containerId = R.id.budget_pill,
            progressGreenId = R.id.budget_progress_green,
            progressYellowId = R.id.budget_progress_yellow,
            progressRedId = R.id.budget_progress_red,
            iconId = R.id.budget_pill_icon,
            labelId = R.id.budget_pill_label,
            valueId = R.id.budget_pill_value,
            iconRes = R.drawable.ic_widget_budget,
        )

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
                    WidgetPillMeterUtils.bind(
                        views = views,
                        ids = budgetPill,
                        label = "Monthly budget",
                        progressPercent = 0,
                        valueText = "Setup",
                        visible = false,
                    )
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.remaining_text,
                        "Set a monthly budget",
                    )
                } else {
                    val spentValue = spent.toLongOrNull() ?: 0L
                    val limitValue = limit.toLongOrNull() ?: 1L
                    val progress = ((spentValue * 100) / limitValue).toInt().coerceIn(0, 100)
                    WidgetPillMeterUtils.bind(
                        views = views,
                        ids = budgetPill,
                        label = "Monthly budget",
                        progressPercent = progress,
                        valueText = "$progress%",
                        visible = true,
                    )
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
