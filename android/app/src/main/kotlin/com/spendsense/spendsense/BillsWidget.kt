package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class BillsWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val json = widgetData.getString("bills_json", "[]") ?: "[]"
        val rows = JSONArray(json)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.bills_widget)
            val rowIds = listOf(
                listOf(R.id.bill1, R.id.bill1_color, R.id.bill1_card, R.id.bill1_meta),
                listOf(R.id.bill2, R.id.bill2_color, R.id.bill2_card, R.id.bill2_meta),
                listOf(R.id.bill3, R.id.bill3_color, R.id.bill3_card, R.id.bill3_meta),
            )

            if (rows.length() == 0) {
                views.setViewVisibility(R.id.empty_text, View.VISIBLE)
                for (ids in rowIds) {
                    views.setViewVisibility(ids[0], View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.empty_text, View.GONE)
                for (index in rowIds.indices) {
                    val ids = rowIds[index]
                    if (index < rows.length()) {
                        val item = rows.getJSONObject(index)
                        val card = item.optString("card_nickname", "Card")
                        val amount = item.optInt("net_outstanding_paise", 0).toString()
                        val color = item.optInt("color_value", 0xFF9E9E9E.toInt())
                        val dueMs = if (item.isNull("due_date_ms")) {
                            0L
                        } else {
                            item.optLong("due_date_ms", 0L)
                        }
                        val dueLabel = if (dueMs > 0L) {
                            WidgetFormatUtils.formatDueDate(dueMs)
                        } else {
                            "Due date pending"
                        }
                        views.setViewVisibility(ids[0], View.VISIBLE)
                        views.setInt(ids[1], "setBackgroundColor", color)
                        views.setTextViewText(ids[2], card)
                        views.setTextViewText(
                            ids[3],
                            "$dueLabel · ${WidgetFormatUtils.formatPaise(amount)}",
                        )
                    } else {
                        views.setViewVisibility(ids[0], View.GONE)
                    }
                }
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
