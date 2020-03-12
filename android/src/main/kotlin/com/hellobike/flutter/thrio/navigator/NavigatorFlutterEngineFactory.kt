package com.hellobike.flutter.thrio.navigator

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.BinaryMessenger

internal object NavigatorFlutterEngineFactory {

    const val THRIO_ENGINE_ID = "__thrio__"

    private val manager = mutableMapOf<Int, NavigatorFlutterEngine>()

    fun initEngine(context: Context, entryPoint: String = THRIO_ENGINE_ID) {
        if (FlutterEngineCache.getInstance().contains(entryPoint)) {
            return
        }
        val engine = FlutterEngine(context)
        val id = engine.dartExecutor.hashCode()
        manager[id] = NavigatorFlutterEngine(id).apply {
            this.entryPoint = entryPoint
        }
        FlutterEngineCache.getInstance().put(entryPoint, engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        onRegister(engine.dartExecutor)
    }

    fun onRegister(binaryMessenger: BinaryMessenger) {
        val id = binaryMessenger.hashCode()
        if (!manager.containsKey(id)) {
            return
        }
        val sendChannel = NavigatorSendChannel(binaryMessenger)
        val receiveChannel = NavigatorReceiveChannel().apply { sendChannel.setMethodCallHandler(this) }
        manager[id]?.run {
            this.sendChannel = sendChannel
            this.receiveChannel = receiveChannel
        }
    }

    fun unRegister(binaryMessenger: BinaryMessenger) {
        val id = binaryMessenger.hashCode()
        if (!manager.containsKey(id)) {
            return
        }
        val engine = manager[id] ?: return
        engine.sendChannel = null
        engine.receiveChannel = null
        manager.remove(id)
    }

    fun getNavigatorFlutterEngine(id: Int): NavigatorFlutterEngine? {
        return manager[id]
    }

    fun getNavigatorFlutterEngine(entryPoint: String = THRIO_ENGINE_ID): NavigatorFlutterEngine? {
        val engine = FlutterEngineCache.getInstance().get(entryPoint) ?: return null
        val id = engine.dartExecutor.hashCode()
        return manager[id]
    }
}