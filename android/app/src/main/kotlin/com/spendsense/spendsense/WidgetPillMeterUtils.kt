package com.spendsense.spendsense

import android.graphics.Color
import android.view.View
import android.widget.RemoteViews

object WidgetPillMeterUtils {
    const val yellowThresholdPercent = 75
    const val redThresholdPercent = 90

    fun bind(
        views: RemoteViews,
        ids: PillMeterIds,
        label: String,
        progressPercent: Int,
        valueText: String,
        visible: Boolean = true,
    ) {
        if (!visible) {
            views.setViewVisibility(ids.containerId, View.GONE)
            return
        }

        val progress = progressPercent.coerceIn(0, 100)

        views.setViewVisibility(ids.containerId, View.VISIBLE)
        bindProgressColor(views, ids, progress)
        views.setImageViewResource(ids.iconId, ids.iconRes)
        views.setTextViewText(ids.labelId, label)
        views.setTextViewText(ids.valueId, valueText)
        views.setTextColor(ids.labelId, Color.WHITE)
        views.setTextColor(ids.valueId, Color.WHITE)
    }

    private fun bindProgressColor(
        views: RemoteViews,
        ids: PillMeterIds,
        progress: Int,
    ) {
        val band = progressColorBand(progress)
        views.setViewVisibility(
            ids.progressGreenId,
            if (band == ProgressColorBand.Green) View.VISIBLE else View.GONE,
        )
        views.setViewVisibility(
            ids.progressYellowId,
            if (band == ProgressColorBand.Yellow) View.VISIBLE else View.GONE,
        )
        views.setViewVisibility(
            ids.progressRedId,
            if (band == ProgressColorBand.Red) View.VISIBLE else View.GONE,
        )

        val activeProgressId = when (band) {
            ProgressColorBand.Green -> ids.progressGreenId
            ProgressColorBand.Yellow -> ids.progressYellowId
            ProgressColorBand.Red -> ids.progressRedId
        }
        views.setProgressBar(activeProgressId, 100, progress, false)
    }

    private fun progressColorBand(progressPercent: Int): ProgressColorBand {
        return when {
            progressPercent >= redThresholdPercent -> ProgressColorBand.Red
            progressPercent >= yellowThresholdPercent -> ProgressColorBand.Yellow
            else -> ProgressColorBand.Green
        }
    }
}

private enum class ProgressColorBand {
    Green,
    Yellow,
    Red,
}

data class PillMeterIds(
    val containerId: Int,
    val progressGreenId: Int,
    val progressYellowId: Int,
    val progressRedId: Int,
    val iconId: Int,
    val labelId: Int,
    val valueId: Int,
    val iconRes: Int,
)
