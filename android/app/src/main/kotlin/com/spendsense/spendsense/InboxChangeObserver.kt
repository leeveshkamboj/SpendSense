package com.spendsense.spendsense

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import android.util.Log

/**
 * Watches SMS/MMS provider writes so RCS/MMS (which never fire SMS_RECEIVED)
 * still trigger a Flutter inbox sync while the app process is alive.
 */
class InboxChangeObserver(
    private val context: Context,
) {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var registered = false
    private var pendingNudge: Runnable? = null

    private val observer = object : ContentObserver(mainHandler) {
        override fun onChange(selfChange: Boolean) {
            onChange(selfChange, null)
        }

        override fun onChange(selfChange: Boolean, uri: Uri?) {
            scheduleNudge()
        }
    }

    fun start() {
        if (registered) {
            return
        }

        try {
            val resolver = context.contentResolver
            resolver.registerContentObserver(Telephony.Sms.CONTENT_URI, true, observer)
            resolver.registerContentObserver(Telephony.Mms.CONTENT_URI, true, observer)
            resolver.registerContentObserver(
                Uri.parse("content://mms-sms/"),
                true,
                observer,
            )
            registered = true
            Log.i(TAG, "[DEBUG-sms] Inbox ContentObserver registered")
        } catch (error: Exception) {
            Log.e(TAG, "[DEBUG-sms] Failed to register inbox observer", error)
        }
    }

    fun stop() {
        if (!registered) {
            return
        }
        try {
            context.contentResolver.unregisterContentObserver(observer)
        } catch (_: Exception) {
        }
        pendingNudge?.let { mainHandler.removeCallbacks(it) }
        pendingNudge = null
        registered = false
    }

    private fun scheduleNudge() {
        // MMS/RCS parts are often written a moment after the PDU row.
        pendingNudge?.let { mainHandler.removeCallbacks(it) }
        val nudge = Runnable {
            Log.i(TAG, "[DEBUG-sms] inbox provider changed — captureOrSync")
            Thread {
                SmsBackgroundEngine.captureOrSync(
                    context = context,
                    body = null,
                    sender = null,
                    receivedAtMs = null,
                )
            }.start()
        }
        pendingNudge = nudge
        mainHandler.postDelayed(nudge, 1500)
    }

    companion object {
        private const val TAG = "SpendSense.Sms"
    }
}
