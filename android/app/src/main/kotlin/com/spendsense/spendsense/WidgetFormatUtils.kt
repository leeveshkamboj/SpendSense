package com.spendsense.spendsense

import java.text.NumberFormat
import java.util.Calendar
import java.util.Locale

object WidgetFormatUtils {
    private val indianLocale = Locale.forLanguageTag("en-IN")

    fun formatPaise(paise: String): String {
        val value = paise.toLongOrNull() ?: return "₹0"
        val rupees = value / 100.0
        val formatter = NumberFormat.getCurrencyInstance(indianLocale)
        if (rupees == rupees.toLong().toDouble()) {
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
        } else {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        }
        return formatter.format(rupees)
    }

    fun formatTime(ms: Long): String {
        val calendar = Calendar.getInstance()
        calendar.timeInMillis = ms
        val day = calendar.get(Calendar.DAY_OF_MONTH).toString().padStart(2, '0')
        val month = (calendar.get(Calendar.MONTH) + 1).toString().padStart(2, '0')
        val hour = calendar.get(Calendar.HOUR_OF_DAY).toString().padStart(2, '0')
        val minute = calendar.get(Calendar.MINUTE).toString().padStart(2, '0')
        return "$day/$month $hour:$minute"
    }

    fun formatDueDate(ms: Long): String {
        val calendar = Calendar.getInstance()
        calendar.timeInMillis = ms
        val day = calendar.get(Calendar.DAY_OF_MONTH).toString().padStart(2, '0')
        val month = (calendar.get(Calendar.MONTH) + 1).toString().padStart(2, '0')
        return "Due $day/$month"
    }
}
