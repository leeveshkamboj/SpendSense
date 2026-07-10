package com.spendsense.spendsense

import android.appwidget.AppWidgetManager
import android.content.Context
import android.view.View
import es.antonborri.home_widget.HomeWidgetProvider

class CreditUtilizationWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        val spent = widgetData.getString("credit_utilization_spent", "0") ?: "0"
        val limit = widgetData.getString("credit_utilization_limit", "") ?: ""
        val needsLimit = widgetData.getString("credit_utilization_needs_limit", "false") == "true"
        val cardsJson = widgetData.getString("credit_utilization_cards_json", "[]") ?: "[]"

        val totalPill = PillMeterIds(
            containerId = R.id.total_pill,
            progressGreenId = R.id.utilization_progress_green,
            progressYellowId = R.id.utilization_progress_yellow,
            progressRedId = R.id.utilization_progress_red,
            iconId = R.id.total_pill_icon,
            labelId = R.id.total_pill_label,
            valueId = R.id.total_pill_value,
            iconRes = R.drawable.ic_widget_credit_card,
        )

        for (widgetId in appWidgetIds) {
            WidgetUpdateUtils.updateSafely(
                context,
                appWidgetManager,
                widgetId,
                R.layout.credit_utilization_widget,
            ) { views ->
                WidgetThemeUtils.applyBaseTheme(context, views, R.id.widget_root)
                WidgetThemeUtils.setHeroAmount(
                    context,
                    views,
                    R.id.spent_text,
                    WidgetFormatUtils.formatPaise(spent),
                )
                WidgetThemeUtils.setBody(
                    context,
                    views,
                    R.id.spent_label,
                    "Current cycle · cards with limits",
                )

                val spentValue = spent.toLongOrNull() ?: 0L
                val limitValue = limit.toLongOrNull() ?: 0L
                val hasConfiguredLimit = limitValue > 0L

                if (!hasConfiguredLimit) {
                    WidgetPillMeterUtils.bind(
                        views = views,
                        ids = totalPill,
                        label = "Credit limits",
                        progressPercent = 0,
                        valueText = "Setup",
                        visible = false,
                    )
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.limit_text,
                        "Set credit limits in Accounts → Card settings",
                    )
                    views.setTextViewText(R.id.remaining_text, "")
                } else {
                    val progress = ((spentValue * 100) / limitValue).toInt().coerceIn(0, 100)
                    WidgetPillMeterUtils.bind(
                        views = views,
                        ids = totalPill,
                        label = "Credit used",
                        progressPercent = progress,
                        valueText = "$progress%",
                        visible = true,
                    )
                    WidgetThemeUtils.setSubtitle(
                        context,
                        views,
                        R.id.limit_text,
                        "of ${WidgetFormatUtils.formatPaise(limit)} credit limit",
                    )
                    val remaining = (limitValue - spentValue).coerceAtLeast(0L)
                    val remainingText = if (needsLimit) {
                        "${WidgetFormatUtils.formatPaise(remaining.toString())} available · " +
                            "set limits on remaining cards"
                    } else {
                        "${WidgetFormatUtils.formatPaise(remaining.toString())} available"
                    }
                    WidgetThemeUtils.setBody(
                        context,
                        views,
                        R.id.remaining_text,
                        remainingText,
                    )
                }

                WidgetChartUtils.bindUtilizationRows(
                    views,
                    cardsJson,
                    listOf(
                        UtilizationRowIds(
                            PillMeterIds(
                                R.id.card_row_1,
                                R.id.card_row_1_progress_green,
                                R.id.card_row_1_progress_yellow,
                                R.id.card_row_1_progress_red,
                                R.id.card_row_1_icon,
                                R.id.card_row_1_name,
                                R.id.card_row_1_amount,
                                R.drawable.ic_widget_credit_card,
                            ),
                        ),
                        UtilizationRowIds(
                            PillMeterIds(
                                R.id.card_row_2,
                                R.id.card_row_2_progress_green,
                                R.id.card_row_2_progress_yellow,
                                R.id.card_row_2_progress_red,
                                R.id.card_row_2_icon,
                                R.id.card_row_2_name,
                                R.id.card_row_2_amount,
                                R.drawable.ic_widget_credit_card,
                            ),
                        ),
                        UtilizationRowIds(
                            PillMeterIds(
                                R.id.card_row_3,
                                R.id.card_row_3_progress_green,
                                R.id.card_row_3_progress_yellow,
                                R.id.card_row_3_progress_red,
                                R.id.card_row_3_icon,
                                R.id.card_row_3_name,
                                R.id.card_row_3_amount,
                                R.drawable.ic_widget_credit_card,
                            ),
                        ),
                    ),
                )

                val rootUri = if (!hasConfiguredLimit) {
                    "spendsense://widget/accounts?setup=1"
                } else {
                    "spendsense://widget/accounts"
                }
                WidgetLaunchUtils.bindLaunch(context, views, R.id.widget_root, rootUri)

                val cards = org.json.JSONArray(cardsJson)
                val cardRowIds = listOf(R.id.card_row_1, R.id.card_row_2, R.id.card_row_3)
                for (index in cardRowIds.indices) {
                    if (index < cards.length()) {
                        val cardId = cards.getJSONObject(index).optInt("card_id", 0)
                        if (cardId > 0) {
                            WidgetLaunchUtils.bindLaunch(
                                context,
                                views,
                                cardRowIds[index],
                                "spendsense://widget/card/$cardId",
                            )
                        }
                    }
                }
            }
        }
    }
}
