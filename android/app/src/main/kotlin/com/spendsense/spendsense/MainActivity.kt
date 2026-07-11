package com.spendsense.spendsense

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun onResume() {
        super.onResume()
        SmsBackgroundEngine.setMainUiResumed(true)
        SmsSyncScheduler.schedule(applicationContext)
    }

    override fun onPause() {
        SmsBackgroundEngine.setMainUiResumed(false)
        super.onPause()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // So SmsReceivedReceiver can nudge the UI isolate when the app is open.
        FlutterEngineCache.getInstance()
            .put(SmsBackgroundEngine.MAIN_ENGINE_ID, flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readInboxSince" -> {
                        val sinceMs = call.argument<Number>("sinceMs")?.toLong()
                        if (sinceMs == null) {
                            result.error("invalid_args", "sinceMs is required", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val messages = SmsInboxReader.readAllMessagesSince(
                                this,
                                sinceMs,
                            )
                            result.success(messages)
                        } catch (error: SecurityException) {
                            result.error("permission_denied", error.message, null)
                        } catch (error: Exception) {
                            result.error("read_failed", error.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        SmsBackgroundEngine.setMainUiResumed(false)
        FlutterEngineCache.getInstance().remove(SmsBackgroundEngine.MAIN_ENGINE_ID)
        super.cleanUpFlutterEngine(flutterEngine)
    }

    companion object {
        private const val CHANNEL = "com.spendsense.spendsense/sms_inbox"
    }
}
