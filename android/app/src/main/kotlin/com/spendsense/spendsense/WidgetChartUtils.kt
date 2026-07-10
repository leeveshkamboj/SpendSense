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
        rowIds: List<Triple<Int, Int, Int>>,
    ) {
        val rows = JSONArray(json)
        if (rows.length() == 0) {
            for ((containerId, _, _) in rowIds) {
                views.setViewVisibility(containerId, View.GONE)
            }
            return
        }

        for (index in rowIds.indices) {
            val (containerId, colorId, progressId) = rowIds[index]
            if (index < rows.length()) {
                val item = rows.getJSONObject(index)
                val spent = item.optInt("spent_paise", 0)
                val limit = item.optInt("credit_limit_paise", 1).coerceAtLeast(1)
                val color = item.optInt("color_value", 0xFF9E9E9E.toInt())
                val progress = ((spent * 100) / limit).coerceIn(0, 100)
                views.setViewVisibility(containerId, View.VISIBLE)
                views.setInt(colorId, "setBackgroundColor", color)
                views.setProgressBar(progressId, 100, progress, false)
            } else {
                views.setViewVisibility(containerId, View.GONE)
            }
        }
    }
}
