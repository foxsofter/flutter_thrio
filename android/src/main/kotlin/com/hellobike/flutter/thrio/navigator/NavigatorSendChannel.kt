package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import com.hellobike.flutter.thrio.channel.ThrioChannel
import com.hellobike.flutter.thrio.Result
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

internal class NavigatorSendChannel constructor(
        private val messenger: BinaryMessenger,
        private val activity: () -> Activity
) {

    private val channel: ThrioChannel by lazy {
        ThrioChannel(messenger, "__thrio_app__").apply {
            val handler = NavigatorReceiveChannel(activity)
            setMethodCallHandler(handler)
        }
    }

    fun onPush(url: String, index: Int, params: Map<String, Any>, animated: Boolean, result: Result) {
        val data = mapOf(
                "url" to url,
                "index" to index,
                "params" to params,
                "animated" to animated
        )
        channel.invokeMethod("__onPush__", data, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
            }

            override fun notImplemented() {}
        })
    }

    fun onPop(url: String, index: Int, animated: Boolean, result: Result) {
        val data = mapOf(
                "url" to url,
                "index" to index,
                "animated" to animated
        )
        channel.invokeMethod("__onPop__", data, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
            }

            override fun notImplemented() {}
        })
    }

    fun onRemove(url: String, index: Int, animated: Boolean, result: Result) {
        val data = mapOf(
                "url" to url,
                "index" to index,
                "animated" to animated
        )
        channel.invokeMethod("__onRemove__", data, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
            }

            override fun notImplemented() {}
        })
    }

    fun onPopTo(url: String, index: Int, animated: Boolean, result: Result) {
        val data = mapOf(
                "url" to url,
                "index" to index,
                "animated" to animated
        )
        channel.invokeMethod("__onPopTo__", data, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
            }

            override fun notImplemented() {}
        })
    }

    fun onNotify(url: String, index: Int, name: String, params: Map<String, Any>) {
        val data = mapOf(
                "url" to url,
                "index" to index,
                "name" to name,
                "params" to params
        )
        channel.invokeMethod("__onNotify__", data)
    }

    fun setPopDisabled(url: String, disabled: Boolean) {
        val data = mapOf(
                "url" to url,
                "disabled" to disabled
        )
        channel.invokeMethod("__onSetPopDisabled__", data)
    }
}