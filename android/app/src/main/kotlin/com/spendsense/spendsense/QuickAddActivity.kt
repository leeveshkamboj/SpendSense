package com.spendsense.spendsense

import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Translucent Flutter activity that hosts a compact quick-add sheet over the
 * launcher. Used by the budget / quick-add home-screen widgets.
 */
class QuickAddActivity : FlutterFragmentActivity() {
    override fun getDartEntrypointFunctionName(): String = "quickAddMain"

    override fun getDartEntrypointLibraryUri(): String =
        "package:spendsense/features/home_widgets/presentation/quick_add_entrypoint.dart"

    override fun getBackgroundMode(): BackgroundMode = BackgroundMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialKind" -> {
                        val kind = intent?.data?.lastPathSegment
                        result.success(kind)
                    }
                    "finish" -> {
                        finish()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        const val CHANNEL = "com.spendsense.spendsense/quick_add"
    }
}
