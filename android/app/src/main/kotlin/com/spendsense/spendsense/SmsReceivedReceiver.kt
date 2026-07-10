package com.spendsense.spendsense

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import androidx.core.content.ContextCompat
import android.Manifest
import android.content.pm.PackageManager

class SmsReceivedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION != intent.action) {
            return
        }

        if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_SMS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "Ignoring SMS because READ_SMS is not granted")
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

                Log.i(
                    TAG,
                    "Incoming SMS from $sender at $receivedAtMs (${body.length} chars)",
                )

                val result = SmsBackgroundEngine.processSms(
                    context = applicationContext,
                    body = body,
                    sender = sender,
                    receivedAtMs = receivedAtMs,
                )
                Log.i(TAG, "Background SMS processed with result=$result")
            } catch (error: Exception) {
                Log.e(TAG, "Failed to process incoming SMS", error)
            } finally {
                pending.finish()
            }
        }.start()
    }

    companion object {
        private const val TAG = "SpendSense.SmsReceiver"
    }
}
