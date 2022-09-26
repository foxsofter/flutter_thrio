package io.flutter.embedding.engine

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.dart.DartExecutor

open class ThrioFlutterEngine private constructor(context: Context, flutterJNI: FlutterJNI?) :
    FlutterEngineWrapper(context, null, flutterJNI) {

    constructor(context: Context) : this(context, null)

    open fun fork(
        context: Context,
        entrypoint: String,
        initialRoute: String?,
        arguments: List<String>?,
    ): ThrioFlutterEngine {
        val dartEntrypoint =
            DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(), entrypoint
            )
        val jniField = FlutterEngine::class.java.getDeclaredField("flutterJNI")
        jniField.isAccessible = true
        val flutterJNI = jniField.get(this) as FlutterJNI

        check(flutterJNI.isAttached) {
            "Spawn can only be called on a fully constructed FlutterEngine"
        }

        val newFlutterJNI = flutterJNI.spawn(
            dartEntrypoint.dartEntrypointFunctionName,
            dartEntrypoint.dartEntrypointLibrary,
            initialRoute,
            arguments
        )
        return ThrioFlutterEngine(context, newFlutterJNI)
    }
}