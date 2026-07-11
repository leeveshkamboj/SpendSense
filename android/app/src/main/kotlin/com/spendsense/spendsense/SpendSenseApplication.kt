package com.spendsense.spendsense

import android.app.Application
import android.util.Log

class SpendSenseApplication : Application() {
    private var inboxObserver: InboxChangeObserver? = null

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "[DEBUG-sms] Application onCreate — starting inbox watch + sync scheduler")
        inboxObserver = InboxChangeObserver(this).also { it.start() }
        SmsSyncScheduler.schedule(this)
    }

    companion object {
        private const val TAG = "SpendSense.Sms"
    }
}
