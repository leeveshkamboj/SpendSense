package com.spendsense.spendsense

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Sideload/debug-only trigger so we can force an inbox sync from adb:
 * adb shell am broadcast -a com.spendsense.spendsense.DEBUG_SYNC_INBOX \
 *   -n com.spendsense.spendsense/.SmsDebugReceiver
 */
class SmsDebugReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION) {
            return
        }

        Log.i(TAG, "[DEBUG-sms] DEBUG_SYNC_INBOX received")
        val pending = goAsync()
        val applicationContext = context.applicationContext
        Thread {
            try {
                val result = SmsBackgroundEngine.captureOrSync(
                    context = applicationContext,
                    body = null,
                    sender = null,
                    receivedAtMs = null,
                )
                Log.i(TAG, "[DEBUG-sms] DEBUG_SYNC_INBOX result=$result")
            } catch (error: Exception) {
                Log.e(TAG, "[DEBUG-sms] DEBUG_SYNC_INBOX failed", error)
            } finally {
                pending.finish()
            }
        }.start()
    }

    companion object {
        const val ACTION = "com.spendsense.spendsense.DEBUG_SYNC_INBOX"
        private const val TAG = "SpendSense.Sms"
    }
}
