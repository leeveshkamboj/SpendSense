package com.spendsense.spendsense

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import android.util.Log

/**
 * MMS / RCS-over-MMS often arrives as WAP_PUSH, not SMS_RECEIVED.
 * Sync the inbox after the provider settles — via UI nudge or background engine.
 */
class MmsPushReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Telephony.Sms.Intents.WAP_PUSH_RECEIVED_ACTION &&
            action != Telephony.Sms.Intents.WAP_PUSH_DELIVER_ACTION
        ) {
            return
        }

        Log.i(TAG, "[DEBUG-sms] MMS/WAP push received action=$action — scheduling inbox sync")
        val pending = goAsync()
        val applicationContext = context.applicationContext
        Handler(Looper.getMainLooper()).postDelayed({
            Thread {
                try {
                    val result = SmsBackgroundEngine.captureOrSync(
                        context = applicationContext,
                        body = null,
                        sender = null,
                        receivedAtMs = null,
                    )
                    Log.i(TAG, "[DEBUG-sms] MMS/WAP sync result=$result")
                } catch (error: Exception) {
                    Log.e(TAG, "[DEBUG-sms] MMS/WAP sync failed", error)
                } finally {
                    pending.finish()
                }
            }.start()
        }, 1500)
    }

    companion object {
        private const val TAG = "SpendSense.Sms"
    }
}
