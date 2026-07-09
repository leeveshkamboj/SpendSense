package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class QuickAddWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val expenseIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("spendsense://quick-add/expense"),
        )
        val incomeIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("spendsense://quick-add/income"),
        )

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.quick_add_widget)
            views.setOnClickPendingIntent(R.id.expense_button, expenseIntent)
            views.setOnClickPendingIntent(R.id.income_button, incomeIntent)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
