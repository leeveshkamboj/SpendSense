package com.spendsense.spendsense

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference

object SmsBackgroundEngine {
    private const val ENGINE_ID = "sms_capture_engine"
    private const val BACKGROUND_CHANNEL = "com.spendsense.spendsense/sms_background"
    private const val READY_CHANNEL = "com.spendsense.spendsense/sms_background_ready"
    private const val ENTRYPOINT = "smsBackgroundMain"

    @Volatile
    private var readyLatch: CountDownLatch? = null

    fun processSms(
        context: Context,
        body: String,
        sender: String,
        receivedAtMs: Long,
    ): String? {
        val engine = ensureEngine(context.applicationContext)
        val latch = CountDownLatch(1)
        val resultRef = AtomicReference<String?>(null)

        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, BACKGROUND_CHANNEL)
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
                    latch.countDown()
                }

                override fun notImplemented() {
                    latch.countDown()
                }
            },
        )

        latch.await(30, TimeUnit.SECONDS)
        return resultRef.get()
    }

    private fun ensureEngine(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { return it }

        readyLatch = CountDownLatch(1)

        val engine = FlutterEngine(context)
        io.flutter.plugins.GeneratedPluginRegistrant.registerWith(engine)

        MethodChannel(engine.dartExecutor.binaryMessenger, READY_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "ready") {
                    readyLatch?.countDown()
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }

        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                ENTRYPOINT,
            ),
        )

        readyLatch?.await(15, TimeUnit.SECONDS)

        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }
}
