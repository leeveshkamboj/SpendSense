package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import es.antonborri.home_widget.HomeWidgetProvider

class QuickAddWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            WidgetUpdateUtils.updateSafely(
                context,
                appWidgetManager,
                widgetId,
                R.layout.quick_add_widget,
            ) { views ->
                WidgetThemeUtils.applyBaseTheme(context, views, R.id.widget_root)

                WidgetLaunchUtils.bindQuickAdd(
                    context = context,
                    views = views,
                    viewId = R.id.expense_button,
                    uri = "spendsense://overlay-add/expense",
                    requestCode = widgetId * 10 + 3,
                )
                WidgetLaunchUtils.bindQuickAdd(
                    context = context,
                    views = views,
                    viewId = R.id.income_button,
                    uri = "spendsense://overlay-add/income",
                    requestCode = widgetId * 10 + 4,
                )
            }
        }
    }
}
