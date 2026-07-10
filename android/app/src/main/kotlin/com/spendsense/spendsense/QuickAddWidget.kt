package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import es.antonborri.home_widget.HomeWidgetLaunchIntent
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
                val expenseIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    android.net.Uri.parse("spendsense://quick-add/expense"),
                )
                val incomeIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    android.net.Uri.parse("spendsense://quick-add/income"),
                )
                views.setOnClickPendingIntent(R.id.expense_button, expenseIntent)
                views.setOnClickPendingIntent(R.id.income_button, incomeIntent)
            }
        }
    }
}
