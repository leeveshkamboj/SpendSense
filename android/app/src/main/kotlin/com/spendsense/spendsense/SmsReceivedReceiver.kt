package com.spendsense.spendsense

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Telephony
import androidx.core.content.ContextCompat

class SmsReceivedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION != intent.action) {
            return
        }

        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_SMS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val pending = goAsync()
        val applicationContext = context.applicationContext

        Thread {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (messages.isNullOrEmpty()) {
                    return@Thread
                }

                val body = messages.joinToString(separator = "") { it.messageBody.orEmpty() }
                if (body.isBlank()) {
                    return@Thread
                }

                val sender = messages.firstOrNull()?.originatingAddress.orEmpty()
                val receivedAtMs = messages.firstOrNull()?.timestampMillis
                    ?: System.currentTimeMillis()

                SmsBackgroundEngine.processSms(
                    context = applicationContext,
                    body = body,
                    sender = sender,
                    receivedAtMs = receivedAtMs,
                )
            } catch (_: Exception) {
                // Ignore background capture failures; foreground sync will retry.
            } finally {
                pending.finish()
            }
        }.start()
    }
}
