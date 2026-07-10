package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class RecentTransactionsWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val json = widgetData.getString("recent_transactions_json", "[]") ?: "[]"
        val rows = JSONArray(json)

        for (widgetId in appWidgetIds) {
            WidgetUpdateUtils.updateSafely(
                context,
                appWidgetManager,
                widgetId,
                R.layout.recent_transactions_widget,
            ) { views ->
                val rowIds = listOf(
                    listOf(R.id.row1, R.id.row1_color, R.id.row1_merchant, R.id.row1_meta),
                    listOf(R.id.row2, R.id.row2_color, R.id.row2_merchant, R.id.row2_meta),
                    listOf(R.id.row3, R.id.row3_color, R.id.row3_merchant, R.id.row3_meta),
                    listOf(R.id.row4, R.id.row4_color, R.id.row4_merchant, R.id.row4_meta),
                    listOf(R.id.row5, R.id.row5_color, R.id.row5_merchant, R.id.row5_meta),
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
                            val merchant = item.optString("merchant", "Unknown")
                            val amount = item.optInt("amount_paise", 0).toString()
                            val atMs = item.optLong("transaction_at_ms", 0L)
                            val color = item.optInt("color_value", 0xFF9E9E9E.toInt())
                            views.setViewVisibility(ids[0], View.VISIBLE)
                            views.setInt(ids[1], "setBackgroundColor", color)
                            views.setTextViewText(ids[2], merchant)
                            views.setTextViewText(
                                ids[3],
                                "${WidgetFormatUtils.formatPaise(amount)} · ${WidgetFormatUtils.formatTime(atMs)}",
                            )
                        } else {
                            views.setViewVisibility(ids[0], View.GONE)
                        }
                    }
                }
            }
        }
    }
}
