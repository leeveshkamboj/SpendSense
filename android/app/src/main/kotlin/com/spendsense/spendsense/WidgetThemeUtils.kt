package com.spendsense.spendsense

import android.content.Context
import android.widget.RemoteViews
import androidx.core.content.ContextCompat

object WidgetThemeUtils {
    fun applyBaseTheme(context: Context, views: RemoteViews, rootId: Int) {
        views.setInt(rootId, "setBackgroundResource", R.drawable.widget_background)
    }

    fun titleColor(context: Context): Int =
        ContextCompat.getColor(context, R.color.widget_text_primary)

    fun secondaryColor(context: Context): Int =
        ContextCompat.getColor(context, R.color.widget_text_secondary)

    fun tertiaryColor(context: Context): Int =
        ContextCompat.getColor(context, R.color.widget_text_tertiary)

    fun accentColor(context: Context): Int =
        ContextCompat.getColor(context, R.color.widget_accent)

    fun debitColor(context: Context): Int =
        ContextCompat.getColor(context, R.color.widget_debit)

    fun creditColor(context: Context): Int =
        ContextCompat.getColor(context, R.color.widget_credit)

    fun setTitle(context: Context, views: RemoteViews, viewId: Int, text: String) {
        views.setTextViewText(viewId, text)
        views.setTextColor(viewId, titleColor(context))
    }

    fun setSubtitle(context: Context, views: RemoteViews, viewId: Int, text: String) {
        views.setTextViewText(viewId, text)
        views.setTextColor(viewId, secondaryColor(context))
    }

    fun setBody(context: Context, views: RemoteViews, viewId: Int, text: String) {
        views.setTextViewText(viewId, text)
        views.setTextColor(viewId, tertiaryColor(context))
    }

    fun setAmount(
        context: Context,
        views: RemoteViews,
        viewId: Int,
        text: String,
        kind: String,
    ) {
        views.setTextViewText(viewId, text)
        views.setTextColor(viewId, amountColorForKind(context, kind))
    }

    fun amountColorForKind(context: Context, kind: String): Int = when {
        isCreditKind(kind) -> creditColor(context)
        kind == "card_payment" -> titleColor(context)
        else -> debitColor(context)
    }

    fun isCreditKind(kind: String): Boolean =
        kind == "refund" || kind == "cashback" || kind == "adjustment_credit" || kind == "credit"

    fun formatSignedAmount(context: Context, amountPaise: Int, kind: String): Pair<String, Boolean> {
        val formatted = WidgetFormatUtils.formatPaise(amountPaise.toString())
        val isCredit = isCreditKind(kind)
        val signed = when {
            isCredit -> "+$formatted"
            kind == "card_payment" -> formatted
            else -> "−$formatted"
        }
        return signed to isCredit
    }
}
