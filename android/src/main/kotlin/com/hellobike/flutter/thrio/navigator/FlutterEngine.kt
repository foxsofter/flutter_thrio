package com.hellobike.flutter.thrio.navigator

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import com.hellobike.flutter.thrio.Result
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

internal data class FlutterEngine(private val context: Context, private val id: String) {

    private var entryPoint: String = id
    private var flutterEngine: FlutterEngine = FlutterEngine(context)
    private var sendChannel: SendChannel
    private var receiveChannel: ReceiveChannel

    private var routeObserverChannel: RouteObserverChannel
    private var pageObserverChannel: PageObserverChannel

    init {
        sendChannel = SendChannel(flutterEngine.dartExecutor, id)
        receiveChannel = ReceiveChannel(id)
        sendChannel.setMethodCallHandler(receiveChannel)

        routeObserverChannel = RouteObserverChannel(flutterEngine.dartExecutor)
        pageObserverChannel = PageObserverChannel(flutterEngine.dartExecutor)

        flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put(entryPoint, flutterEngine)
    }

    fun onPush(record: PageRoute, isNested: Boolean, result: Result) {
        sendChannel.onPush(record.url, record.index, record.params, record.animated, isNested, result)
    }

    fun onPop(record: PageRoute, result: Result) {
        sendChannel.onPop(record.url, record.index, record.resultParams, record.animated, result)
    }

    fun onRemove(url: String, index: Int, animated: Boolean, result: Result) {
        sendChannel.onRemove(url, index, animated, result)
    }

    fun onPopTo(url: String, index: Int, animated: Boolean, result: Result) {
        sendChannel.onPopTo(url, index, animated, result)
    }

    fun onNotify(url: String, index: Int, name: String, params: Any?) {
        sendChannel.onNotify(url, index, name, params)
    }
}