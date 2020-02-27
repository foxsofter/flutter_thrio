package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class NavigatorReceiveChannel constructor(
        private val activity: () -> Activity
) : MethodChannel.MethodCallHandler {

    private fun push(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val params = call.argument<Map<String, Any>>("params") ?: emptyMap()
        val animated = call.argument<Boolean>("animated") ?: true
        NavigatorController.push(activity(), url, params, animated) {
            result.success(it)
        }
    }

    private fun pop(call: MethodCall, result: MethodChannel.Result) {
        val animated = call.argument<Boolean>("animated") ?: true
        NavigatorController.pop(activity(), animated) {
            result.success(it)
        }
    }

    private fun remove(call: MethodCall, result: MethodChannel.Result) {
        // 暂不可用
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val index = call.argument<Int>("index")
        if (index == null || index < 0) {
            result.success(false)
            return
        }
        val animated = call.argument<Boolean>("animated") ?: true
        NavigatorController.remove(activity(), url, index, animated) {
            result.success(it)
        }
    }


    private fun popTo(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val index = call.argument<Int>("index")
        if (index == null || index < 0) {
            result.success(false)
            return
        }
        val animated = call.argument<Boolean>("animated") ?: true
        NavigatorController.popTo(activity(), url, index, animated) {
            result.success(it)
        }
    }

    private fun notify(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val index = call.argument<Int>("index")
        if (index == null || index < 0) {
            result.success(false)
            return
        }
        val name = call.argument<String>("name")
        if (name.isNullOrBlank()) {
            result.success(false)
            return
        }
        val params = call.argument<Map<String, Any>>("params") ?: emptyMap()
        NavigatorController.notify(url, index, name, params) {
            result.success(it)
        }
    }

    private fun setPopDisabled(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val index = call.argument<Int>("index")
        if (index == null || index < 0) {
            result.success(false)
            return
        }
        val disable = call.argument<Boolean>("disabled")
        if (disable == null) {
            result.success(false)
            return
        }
        NavigatorController.setPopDisabled(url, index, disable) {
            result.success(it)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.e("Thrio", "flutter call method ${call.method}")
        when (call.method) {
            /** push **/
            "push" -> push(call, result)
            "didPush" -> {
            }
            /** pop **/
            "pop" -> pop(call, result)
            "didPop" -> {
            }
            /** remove **/
            "remove" -> remove(call, result)
            "didRemove" -> {
            }
            /** popTo **/
            "popTo" -> popTo(call, result)
            "didPopTo" -> {
            }
            /** notify **/
            "notify" -> notify(call, result)
            /** popDisabled **/
            "setPopDisabled" -> setPopDisabled(call, result)
            /** hotRestart **/
            "hotRestart" -> {
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}
