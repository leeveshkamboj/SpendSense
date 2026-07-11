package com.spendsense.spendsense

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference

object SmsBackgroundEngine {
    private const val TAG = "SpendSense.Sms"
    private const val ENGINE_ID = "sms_capture_engine"
    const val MAIN_ENGINE_ID = "spendsense_main_engine"
    private const val BACKGROUND_CHANNEL = "com.spendsense.spendsense/sms_background"
    private const val READY_CHANNEL = "com.spendsense.spendsense/sms_background_ready"
    private const val SYNC_NUDGE_CHANNEL = "com.spendsense.spendsense/sms_sync_nudge"
    private const val INBOX_CHANNEL = "com.spendsense.spendsense/sms_inbox"
    private const val ENTRYPOINT_LIBRARY =
        "package:spendsense/features/sms_capture/background/sms_background_handler.dart"
    private const val ENTRYPOINT = "smsBackgroundMain"

    private val lock = Any()
    private val engineReady = AtomicBoolean(false)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val mainUiResumed = AtomicBoolean(false)

    @Volatile
    private var readyLatch: CountDownLatch? = null

    fun setMainUiResumed(resumed: Boolean) {
        mainUiResumed.set(resumed)
        Log.i(TAG, "[DEBUG-sms] mainUiResumed=$resumed")
    }

    fun isMainIsolateAlive(): Boolean {
        return FlutterEngineCache.getInstance().get(MAIN_ENGINE_ID) != null
    }

    /**
     * Prefer immediate processing of the SMS PDU body when present.
     * Fall back to inbox sync for MMS/RCS/alarms. Nudge the UI when alive.
     */
    fun captureOrSync(
        context: Context,
        body: String?,
        sender: String?,
        receivedAtMs: Long?,
    ): String? {
        if (!body.isNullOrBlank() && receivedAtMs != null) {
            if (mainUiResumed.get() && isMainIsolateAlive()) {
                Log.i(
                    TAG,
                    "[DEBUG-sms] mainResumed=true — deliver processSms to UI " +
                        "sender=$sender bodyLen=${body.length}",
                )
                val delivered = deliverProcessSmsToMain(
                    body = body,
                    sender = sender.orEmpty(),
                    receivedAtMs = receivedAtMs,
                )
                if (delivered) {
                    return "delivered_main"
                }
                Log.w(TAG, "[DEBUG-sms] main deliver failed — falling back to background")
            }

            Log.i(
                TAG,
                "[DEBUG-sms] mainResumed=${mainUiResumed.get()} — background processSms " +
                    "sender=$sender bodyLen=${body.length}",
            )
            val result = processSms(
                context = context,
                body = body,
                sender = sender.orEmpty(),
                receivedAtMs = receivedAtMs,
            )
            nudgeMainIsolate()
            Log.i(TAG, "[DEBUG-sms] background processSms result=$result")
            return result
        }

        if (mainUiResumed.get() && isMainIsolateAlive()) {
            Log.i(TAG, "[DEBUG-sms] mainResumed=true — nudge syncNow (no PDU body)")
            nudgeMainIsolate()
            return "nudged"
        }

        Log.i(
            TAG,
            "[DEBUG-sms] mainResumed=${mainUiResumed.get()} — background syncInbox",
        )
        val result = syncInbox(context)
        nudgeMainIsolate()
        return result
    }

    private fun deliverProcessSmsToMain(
        body: String,
        sender: String,
        receivedAtMs: Long,
    ): Boolean {
        val mainEngine = FlutterEngineCache.getInstance().get(MAIN_ENGINE_ID) ?: return false
        mainHandler.post {
            try {
                MethodChannel(mainEngine.dartExecutor.binaryMessenger, SYNC_NUDGE_CHANNEL)
                    .invokeMethod(
                        "processSms",
                        mapOf(
                            "body" to body,
                            "sender" to sender,
                            "receivedAtMs" to receivedAtMs,
                        ),
                    )
            } catch (error: Exception) {
                Log.w(TAG, "[DEBUG-sms] Failed to deliver processSms to main", error)
            }
        }
        return true
    }

    fun processSms(
        context: Context,
        body: String,
        sender: String,
        receivedAtMs: Long,
    ): String? {
        val engine = try {
            ensureEngine(context.applicationContext)
        } catch (error: Exception) {
            Log.e(TAG, "[DEBUG-sms] Failed to start SMS background engine", error)
            nudgeMainIsolate()
            return null
        }

        val latch = CountDownLatch(1)
        val resultRef = AtomicReference<String?>(null)

        mainHandler.post {
            try {
                val channel =
                    MethodChannel(engine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL)
                channel.invokeMethod(
                    "processSms",
                    mapOf(
                        "body" to body,
                        "sender" to sender,
                        "receivedAtMs" to receivedAtMs,
                    ),
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            val map = result as? Map<*, *>
                            resultRef.set(map?.get("result") as? String)
                            latch.countDown()
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?,
                        ) {
                            Log.e(
                                TAG,
                                "[DEBUG-sms] processSms error: $errorCode $errorMessage",
                            )
                            latch.countDown()
                        }

                        override fun notImplemented() {
                            Log.e(
                                TAG,
                                "[DEBUG-sms] processSms notImplemented — Dart entrypoint missing?",
                            )
                            latch.countDown()
                        }
                    },
                )
            } catch (error: Exception) {
                Log.e(TAG, "[DEBUG-sms] Failed to invoke processSms", error)
                latch.countDown()
            }
        }

        val completed = latch.await(25, TimeUnit.SECONDS)
        if (!completed) {
            Log.e(TAG, "[DEBUG-sms] processSms timed out after 25s")
        }
        return resultRef.get()
    }

    fun syncInbox(context: Context): String? {
        val engine = try {
            ensureEngine(context.applicationContext)
        } catch (error: Exception) {
            Log.e(TAG, "[DEBUG-sms] Failed to start engine for syncInbox", error)
            nudgeMainIsolate()
            return null
        }

        val latch = CountDownLatch(1)
        val resultRef = AtomicReference<String?>(null)

        mainHandler.post {
            try {
                val channel =
                    MethodChannel(engine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL)
                channel.invokeMethod(
                    "syncInbox",
                    null,
                    object : MethodChannel.Result {
                        override fun success(result: Any?) {
                            val map = result as? Map<*, *>
                            resultRef.set(map?.toString())
                            Log.i(TAG, "[DEBUG-sms] syncInbox dart result=$map")
                            latch.countDown()
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?,
                        ) {
                            Log.e(
                                TAG,
                                "[DEBUG-sms] syncInbox error: $errorCode $errorMessage",
                            )
                            latch.countDown()
                        }

                        override fun notImplemented() {
                            Log.e(TAG, "[DEBUG-sms] syncInbox notImplemented")
                            latch.countDown()
                        }
                    },
                )
            } catch (error: Exception) {
                Log.e(TAG, "[DEBUG-sms] Failed to invoke syncInbox", error)
                latch.countDown()
            }
        }

        val completed = latch.await(45, TimeUnit.SECONDS)
        if (!completed) {
            Log.e(TAG, "[DEBUG-sms] syncInbox timed out after 45s")
        }
        return resultRef.get()
    }

    /** Ask the UI isolate to refresh / catch up when the app process is alive. */
    fun nudgeMainIsolate() {
        val mainEngine = FlutterEngineCache.getInstance().get(MAIN_ENGINE_ID)
        if (mainEngine == null) {
            Log.i(TAG, "[DEBUG-sms] nudge skipped — main engine not cached")
            return
        }
        mainHandler.post {
            try {
                Log.i(TAG, "[DEBUG-sms] invoking syncNow on main isolate")
                MethodChannel(mainEngine.dartExecutor.binaryMessenger, SYNC_NUDGE_CHANNEL)
                    .invokeMethod("syncNow", null)
            } catch (error: Exception) {
                Log.w(TAG, "[DEBUG-sms] Failed to nudge main isolate", error)
            }
        }
    }

    private fun ensureEngine(context: Context): FlutterEngine {
        synchronized(lock) {
            FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { cached ->
                if (engineReady.get()) {
                    Log.i(TAG, "[DEBUG-sms] reusing ready background engine")
                    return cached
                }
                Log.w(TAG, "[DEBUG-sms] discarding unready cached engine")
                FlutterEngineCache.getInstance().remove(ENGINE_ID)
                mainHandler.post {
                    try {
                        cached.destroy()
                    } catch (_: Exception) {
                    }
                }
            }

            val ready = CountDownLatch(1)
            readyLatch = ready
            engineReady.set(false)

            val engineRef = AtomicReference<FlutterEngine?>()
            val created = CountDownLatch(1)
            var createError: Exception? = null

            mainHandler.post {
                try {
                    Log.i(TAG, "[DEBUG-sms] creating background FlutterEngine")
                    val loader = FlutterInjector.instance().flutterLoader()
                    if (!loader.initialized()) {
                        loader.startInitialization(context)
                        loader.ensureInitializationComplete(context, null)
                    }

                    val engine = FlutterEngine(context)
                    io.flutter.plugins.GeneratedPluginRegistrant.registerWith(engine)

                    MethodChannel(engine.dartExecutor.binaryMessenger, READY_CHANNEL)
                        .setMethodCallHandler { call, result ->
                            if (call.method == "ready") {
                                Log.i(TAG, "[DEBUG-sms] Dart background entrypoint ready")
                                readyLatch?.countDown()
                                result.success(null)
                            } else {
                                result.notImplemented()
                            }
                        }

                    // Same inbox channel as MainActivity so background sync can read SMS/MMS.
                    MethodChannel(engine.dartExecutor.binaryMessenger, INBOX_CHANNEL)
                        .setMethodCallHandler { call, result ->
                            when (call.method) {
                                "readInboxSince" -> {
                                    val sinceMs = call.argument<Number>("sinceMs")?.toLong()
                                    if (sinceMs == null) {
                                        result.error("invalid_args", "sinceMs is required", null)
                                        return@setMethodCallHandler
                                    }
                                    try {
                                        result.success(
                                            SmsInboxReader.readAllMessagesSince(context, sinceMs),
                                        )
                                    } catch (error: SecurityException) {
                                        result.error("permission_denied", error.message, null)
                                    } catch (error: Exception) {
                                        result.error("read_failed", error.message, null)
                                    }
                                }
                                else -> result.notImplemented()
                            }
                        }

                    engine.dartExecutor.executeDartEntrypoint(
                        DartExecutor.DartEntrypoint(
                            loader.findAppBundlePath(),
                            ENTRYPOINT_LIBRARY,
                            ENTRYPOINT,
                        ),
                    )
                    engineRef.set(engine)
                } catch (error: Exception) {
                    createError = error
                    ready.countDown()
                } finally {
                    created.countDown()
                }
            }

            if (!created.await(20, TimeUnit.SECONDS)) {
                throw IllegalStateException("Timed out creating FlutterEngine")
            }
            createError?.let { throw it }

            val engine = engineRef.get()
                ?: throw IllegalStateException("FlutterEngine was not created")

            val becameReady = ready.await(20, TimeUnit.SECONDS)
            if (!becameReady) {
                mainHandler.post {
                    try {
                        engine.destroy()
                    } catch (_: Exception) {
                    }
                }
                throw IllegalStateException("Dart SMS entrypoint never became ready")
            }

            engineReady.set(true)
            FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
            Log.i(TAG, "[DEBUG-sms] background engine cached and ready")
            return engine
        }
    }
}
