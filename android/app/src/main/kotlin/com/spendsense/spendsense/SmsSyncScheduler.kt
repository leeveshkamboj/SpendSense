package com.spendsense.spendsense

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.util.Log

/**
 * Safety net when OEM SMS_RECEIVED delivery is flaky: wake and sync the
 * SMS/MMS inbox on a short interval while the user has granted SMS access.
 */
object SmsSyncScheduler {
    private const val TAG = "SpendSense.Sms"
    private const val REQUEST_CODE = 71011
    const val INTERVAL_MS = 15 * 60 * 1000L

    fun schedule(context: Context) {
        val appContext = context.applicationContext
        val alarmManager = appContext.getSystemService(AlarmManager::class.java) ?: return
        val pending = pendingIntent(appContext)

        val triggerAt = SystemClock.elapsedRealtime() + INTERVAL_MS
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pending,
                )
            } else {
                @Suppress("DEPRECATION")
                alarmManager.set(
                    AlarmManager.ELAPSED_REALTIME_WAKEUP,
                    triggerAt,
                    pending,
                )
            }
            Log.i(TAG, "[DEBUG-sms] scheduled inbox sync alarm in ${INTERVAL_MS}ms")
        } catch (error: Exception) {
            Log.e(TAG, "[DEBUG-sms] failed to schedule inbox sync alarm", error)
        }
    }

    private fun pendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, SmsSyncAlarmReceiver::class.java).apply {
            action = SmsSyncAlarmReceiver.ACTION
        }
        return PendingIntent.getBroadcast(
            context,
            REQUEST_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}
