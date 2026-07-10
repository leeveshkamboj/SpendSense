package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.util.Log
import android.widget.RemoteViews

object WidgetUpdateUtils {
    private const val TAG = "SpendSense.Widget"

    fun updateSafely(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        layoutId: Int,
        block: (RemoteViews) -> Unit,
    ) {
        try {
            val views = RemoteViews(context.packageName, layoutId)
            block(views)
            appWidgetManager.updateAppWidget(widgetId, views)
        } catch (error: Exception) {
            Log.e(TAG, "Failed to update widget $widgetId (layout=$layoutId)", error)
        }
    }
}
