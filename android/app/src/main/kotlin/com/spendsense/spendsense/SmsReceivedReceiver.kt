package com.spendsense.spendsense

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.provider.Telephony
import android.util.Log
import androidx.core.content.ContextCompat

class SmsReceivedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.i(TAG, "[DEBUG-sms] SMS_RECEIVED action=${intent.action}")
        if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION != intent.action) {
            return
        }

        if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECEIVE_SMS)
            != PackageManager.PERMISSION_GRANTED &&
            ContextCompat.checkSelfPermission(context, Manifest.permission.READ_SMS)
            != PackageManager.PERMISSION_GRANTED
        ) {
            Log.w(TAG, "[DEBUG-sms] SMS permission missing; skipping background capture")
            return
        }

        val pending = goAsync()
        val applicationContext = context.applicationContext

        Thread {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (messages.isNullOrEmpty()) {
                    Log.w(TAG, "[DEBUG-sms] SMS_RECEIVED with empty PDU list — syncInbox fallback")
                    SmsBackgroundEngine.captureOrSync(
                        context = applicationContext,
                        body = null,
                        sender = null,
                        receivedAtMs = null,
                    )
                    return@Thread
                }

                val body = messages.joinToString(separator = "") { it.messageBody.orEmpty() }
                if (body.isBlank()) {
                    Log.w(TAG, "[DEBUG-sms] SMS_RECEIVED blank body — syncInbox fallback")
                    SmsBackgroundEngine.captureOrSync(
                        context = applicationContext,
                        body = null,
                        sender = null,
                        receivedAtMs = null,
                    )
                    return@Thread
                }

                val sender = messages.firstOrNull()?.originatingAddress.orEmpty()
                val receivedAtMs = messages.firstOrNull()?.timestampMillis
                    ?: System.currentTimeMillis()

                Log.i(
                    TAG,
                    "[DEBUG-sms] SMS_RECEIVED sender=$sender bodyLen=${body.length} " +
                        "receivedAtMs=$receivedAtMs",
                )

                val result = SmsBackgroundEngine.captureOrSync(
                    context = applicationContext,
                    body = body,
                    sender = sender,
                    receivedAtMs = receivedAtMs,
                )
                Log.i(TAG, "[DEBUG-sms] SMS_RECEIVED done result=$result sender=$sender")
            } catch (error: Exception) {
                Log.e(TAG, "[DEBUG-sms] Background SMS capture failed", error)
                SmsBackgroundEngine.captureOrSync(
                    context = applicationContext,
                    body = null,
                    sender = null,
                    receivedAtMs = null,
                )
            } finally {
                pending.finish()
            }
        }.start()
    }

    companion object {
        private const val TAG = "SpendSense.Sms"
    }
}
