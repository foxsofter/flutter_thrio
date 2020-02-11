package com.hellobike.flutter.thrio.channel

import android.content.Context
import android.util.Log
import com.hellobike.flutter.thrio.data.Record
import com.hellobike.flutter.thrio.navigator.NavigatorManager
import com.hellobike.flutter.thrio.navigator.ThrioActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class ThrioChannel constructor(
        private val context: Context,
        private val messenger: BinaryMessenger
) : MethodChannel.MethodCallHandler {

    private val channel: FlutterChannel by lazy {
        FlutterChannel(messenger, "__thrio_app__").apply {
            setMethodCallHandler(this@ThrioChannel)
        }
    }

    fun onPush(record: Record) {
        val data = mapOf(
                "url" to record.url,
                "index" to record.index
        )
        channel.invokeMethod("__onPush__", data)
    }

    fun onPop(record: Record) {
        val data = mapOf(
                "url" to record.url,
                "index" to record.index
        )
        channel.invokeMethod("__onPop__", data)
    }

    private fun pushFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("ERROR 1", "ArgumentError url not found", "Please check argument Key or Type.")
            return
        }
        if (NavigatorManager.hasPageBuilder(url)) {
            NavigatorManager.runPageBuilder(url)
            result.success(true)
            return
        }
        ThrioActivity.push(context, url)
        result.success(true)
    }

    private fun popFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        ThrioActivity.pop(context)
        result.success(true)
    }

    private fun popToFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("ERROR 1", "ArgumentError url not found", "Please check argument Key or Type.")
            return
        }
        val index: Int? = call.argument<Int>("index")
        if (index == null) {
            result.error("ERROR 1", "ArgumentError url not found", "Please check argument Key or Type.")
            return
        }
//        context.lif
        ThrioActivity.popTo(context, url, index)
        result.success(true)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        Log.e("Thrio", "flutter call method ${call.method}")
        when (call.method) {
            /** push **/
            "push" -> pushFromFlutter(call, result)
//            "didpush"->

            "pop" -> popFromFlutter(call, result)
//            "didPop" -> didPopFromFlutter(call, result)
//            "didRemove"->
            "popTo" -> popToFromFlutter(call, result)
            else -> result.notImplemented()
        }
    }


}