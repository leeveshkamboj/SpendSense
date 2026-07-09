package com.spendsense.spendsense

import java.util.Calendar

object WidgetFormatUtils {
    fun formatPaise(paise: String): String {
        val value = paise.toLongOrNull() ?: return "₹0"
        val rupees = value / 100.0
        return if (rupees == rupees.toLong().toDouble()) {
            "₹${rupees.toLong()}"
        } else {
            "₹$rupees"
        }
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
