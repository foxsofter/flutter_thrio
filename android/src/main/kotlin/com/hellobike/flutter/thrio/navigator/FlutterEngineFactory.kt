package com.hellobike.flutter.thrio.navigator

import android.content.Context
import io.flutter.embedding.engine.FlutterEngineCache

internal object FlutterEngineFactory {

    const val THRIO_ENGINE_FLUTTER_ID = "__thrio__"
    const val THRIO_ENGINE_NATIVE_ID = "__thrio__native__"

    private val manager = mutableMapOf<String, FlutterEngine>()

    fun startup(context: Context, entryPoint: String = THRIO_ENGINE_FLUTTER_ID) {
        if (FlutterEngineCache.getInstance().contains(entryPoint)) {
            return
        }
        val engine = FlutterEngine(context, entryPoint)
        manager[entryPoint] = engine
    }

    fun getEngine(entryPoint: String = THRIO_ENGINE_FLUTTER_ID): FlutterEngine? {
        return manager[entryPoint]
    }
}