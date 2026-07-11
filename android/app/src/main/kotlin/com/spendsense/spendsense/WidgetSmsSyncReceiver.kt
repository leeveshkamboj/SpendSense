package com.spendsense.spendsense

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast

/**
 * Runs an inbox sync from the budget widget without opening the app.
 * Useful for late RCS/MMS bodies that weren't captured instantly.
 */
class WidgetSmsSyncReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != ACTION) {
            return
        }

        val appContext = context.applicationContext
        val pending = goAsync()
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(
                appContext,
                R.string.budget_widget_sync_started,
                Toast.LENGTH_SHORT,
            ).show()
        }

        Thread {
            var ok = false
            try {
                Log.i(TAG, "[DEBUG-sms] widget sync requested")
                val result = SmsBackgroundEngine.syncInbox(appContext)
                SmsBackgroundEngine.nudgeMainIsolate()
                Log.i(TAG, "[DEBUG-sms] widget sync result=$result")
                ok = true
            } catch (error: Exception) {
                Log.e(TAG, "[DEBUG-sms] widget sync failed", error)
            } finally {
                Handler(Looper.getMainLooper()).post {
                    Toast.makeText(
                        appContext,
                        if (ok) {
                            R.string.budget_widget_sync_done
                        } else {
                            R.string.budget_widget_sync_failed
                        },
                        Toast.LENGTH_SHORT,
                    ).show()
                }
                pending.finish()
            }
        }.start()
    }

    companion object {
        const val ACTION = "com.spendsense.spendsense.WIDGET_SYNC_INBOX"
        private const val TAG = "SpendSense.Sms"
    }
}
