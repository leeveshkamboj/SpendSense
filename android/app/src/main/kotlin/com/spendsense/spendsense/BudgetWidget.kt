package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
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
                        R.id.daily_text,
                        "Set a monthly budget",
                    )
                    views.setTextViewText(R.id.remaining_text, "")
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
                // Body taps open the app; action buttons have their own intents.
                WidgetLaunchUtils.bindLaunch(context, views, R.id.spent_text, launchUri)
                WidgetLaunchUtils.bindLaunch(context, views, R.id.budget_pill, launchUri)
                WidgetLaunchUtils.bindLaunch(context, views, R.id.daily_text, launchUri)
                WidgetLaunchUtils.bindLaunch(context, views, R.id.remaining_text, launchUri)

                WidgetLaunchUtils.bindBroadcast(
                    context = context,
                    views = views,
                    viewId = R.id.sync_button,
                    action = WidgetSmsSyncReceiver.ACTION,
                    requestCode = widgetId * 10 + 1,
                )
                WidgetLaunchUtils.bindQuickAdd(
                    context = context,
                    views = views,
                    viewId = R.id.add_button,
                    // Distinct URI so stale MainActivity PendingIntents for
                    // spendsense://quick-add/* cannot win after an upgrade.
                    uri = "spendsense://overlay-add/expense",
                    requestCode = widgetId * 10 + 2,
                )
            }
        }
    }
}
