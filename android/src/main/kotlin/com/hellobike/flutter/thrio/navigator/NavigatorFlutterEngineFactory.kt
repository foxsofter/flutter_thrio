package com.hellobike.flutter.thrio.navigator

import android.content.Context
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

internal object NavigatorFlutterEngineFactory {

    const val THRIO_ENGINE_ID = "__thrio__"
    const val THRIO_ENGINE_NATIVE_ID = "__thrio__native__"

    private val manager = mutableMapOf<String, NavigatorFlutterEngine>()

    fun initEngine(context: Context, entryPoint: String = THRIO_ENGINE_ID) {
        if (FlutterEngineCache.getInstance().contains(entryPoint)) {
            return
        }
        val engine = NavigatorFlutterEngine(context, entryPoint)
        manager[entryPoint] = engine
        FlutterEngineCache.getInstance().put(entryPoint, engine.flutterEngine)
        engine.flutterEngine
                .dartExecutor
                .executeDartEntrypoint(
                        DartExecutor.DartEntrypoint.createDefault()
                )
    }

    fun getNavigatorFlutterEngine(entryPoint: String = THRIO_ENGINE_ID): NavigatorFlutterEngine? {
        return manager[entryPoint]
    }
}