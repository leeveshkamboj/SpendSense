package com.spendsense.spendsense

object CardNetworkIcons {
    fun iconRes(network: String?): Int {
        return when (network?.trim()?.lowercase()) {
            "visa" -> R.drawable.ic_network_visa
            "mastercard", "mc" -> R.drawable.ic_network_mastercard
            "rupay" -> R.drawable.ic_network_rupay
            "amex", "americanexpress" -> R.drawable.ic_network_amex
            else -> R.drawable.ic_widget_credit_card
        }
    }
}
