package com.hellobike.flutter.thrio.channel


import android.app.Activity
import android.content.Context
import com.hellobike.flutter.thrio.data.Record
import com.hellobike.flutter.thrio.navigator.ActivityManager
import com.hellobike.flutter.thrio.navigator.NavigationController
import com.hellobike.flutter.thrio.navigator.ThrioActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class ThrioChannel constructor(
        private val messenger: BinaryMessenger,
        private val activity: () -> Activity?
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

    fun onPopTo(record: Record) {
        val data = mapOf(
                "url" to record.url,
                "index" to record.index
        )
        channel.invokeMethod("__onPopTo__", data)
    }

    private fun pushFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        val context = activity()
        if (context == null) {
            result.error("ERROR 2", "IllegalStateError topActivity not found", null)
            return
        }
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("ERROR 1", "ArgumentError url not found", null)
            return
        }
        if (NavigationController.hasNavigationBuilder(url)) {
            NavigationController.navigation(context, url)
            result.success(true)
            return
        }
        ThrioActivity.push(context, url)
        result.success(true)
    }

    private fun popFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        val context = activity()
        if (context == null) {
            result.error("ERROR 2", "IllegalStateError topActivity not found", null)
            return
        }
        ThrioActivity.pop(context)
        result.success(true)
    }

    private fun popToFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        val context = activity()
        if (context == null) {
            result.error("ERROR 2", "IllegalStateError topActivity not found", null)
            return
        }
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("ERROR 1", "ArgumentError url not found", null)
            return
        }
        val index: Int? = call.argument<Int>("index")
        if (index == null) {
            result.error("ERROR 1", "ArgumentError index not found", null)
            return
        }
        if (NavigationController.hasNavigationBuilder(url)) {
            NavigationController.popTo(context, url, index)
            result.success(true)
            return
        }
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