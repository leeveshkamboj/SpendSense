package com.spendsense.spendsense

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class SmsSyncAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != ACTION &&
            intent?.action != Intent.ACTION_BOOT_COMPLETED
        ) {
            return
        }

        Log.i(TAG, "[DEBUG-sms] alarm/boot sync action=${intent.action}")
        val pending = goAsync()
        val appContext = context.applicationContext
        Thread {
            try {
                val result = SmsBackgroundEngine.captureOrSync(
                    context = appContext,
                    body = null,
                    sender = null,
                    receivedAtMs = null,
                )
                Log.i(TAG, "[DEBUG-sms] alarm/boot sync result=$result")
            } catch (error: Exception) {
                Log.e(TAG, "[DEBUG-sms] alarm/boot sync failed", error)
            } finally {
                SmsSyncScheduler.schedule(appContext)
                pending.finish()
            }
        }.start()
    }

    companion object {
        const val ACTION = "com.spendsense.spendsense.ALARM_SYNC_INBOX"
        private const val TAG = "SpendSense.Sms"
    }
}
