package com.spendsense.spendsense

import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray

object WidgetChartUtils {
    fun bindStackedSpendChart(
        views: RemoteViews,
        json: String,
        containerId: Int,
        segmentIds: List<Int>,
    ) {
        val rows = JSONArray(json)
        if (rows.length() == 0) {
            views.setViewVisibility(containerId, View.GONE)
            return
        }

        var total = 0L
        for (index in 0 until rows.length()) {
            total += rows.getJSONObject(index).optInt("spent_paise", 0)
        }
        if (total <= 0L) {
            views.setViewVisibility(containerId, View.GONE)
            return
        }

        views.setViewVisibility(containerId, View.VISIBLE)
        val visibleCount = minOf(rows.length(), segmentIds.size)
        for (index in segmentIds.indices) {
            val segmentId = segmentIds[index]
            if (index < visibleCount) {
                val item = rows.getJSONObject(index)
                val color = item.optInt("color_value", 0xFF9E9E9E.toInt())
                views.setViewVisibility(segmentId, View.VISIBLE)
                views.setInt(segmentId, "setBackgroundColor", color)
            } else {
                views.setViewVisibility(segmentId, View.GONE)
            }
        }
    }

    fun bindUtilizationRows(
        views: RemoteViews,
        json: String,
        rowIds: List<UtilizationRowIds>,
    ) {
        val rows = JSONArray(json)
        if (rows.length() == 0) {
            for (row in rowIds) {
                views.setViewVisibility(row.pill.containerId, View.GONE)
            }
            return
        }

        for (index in rowIds.indices) {
            val row = rowIds[index]
            if (index < rows.length()) {
                val item = rows.getJSONObject(index)
                val spent = item.optInt("spent_paise", 0)
                val limit = item.optInt("credit_limit_paise", 1).coerceAtLeast(1)
                val nickname = item.optString("nickname", "Card")
                val network = item.optString("network", "")
                val progress = ((spent * 100) / limit).coerceIn(0, 100)
                WidgetPillMeterUtils.bind(
                    views = views,
                    ids = row.pill.copy(
                        iconRes = CardNetworkIcons.iconRes(network),
                    ),
                    label = nickname,
                    progressPercent = progress,
                    valueText = "$progress%",
                    visible = true,
                )
            } else {
                views.setViewVisibility(row.pill.containerId, View.GONE)
            }
        }
    }
}

data class UtilizationRowIds(
    val pill: PillMeterIds,
)
