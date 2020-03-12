// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

package com.hellobike.flutter.thrio.navigator

import android.util.Log
import com.hellobike.flutter.thrio.Result
import com.hellobike.flutter.thrio.channel.ThrioChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

internal class NavigatorSendChannel constructor(messenger: BinaryMessenger)
    : ThrioChannel(messenger, "__thrio_app__"), EventChannel.StreamHandler {

    init {
        setStreamHandler(this)
    }

    private var sink: EventChannel.EventSink? = null

    fun onPush(url: String, index: Int, params: Any?, animated: Boolean, result: Result) {
        val data = mapOf(
                "url" to url,
                "index" to index,
                "params" to params,
                "animated" to animated
        )
        invokeMethod("__onPush__", data, object : MethodChannel.Result {
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
        invokeMethod("__onPop__", data, object : MethodChannel.Result {
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
        invokeMethod("__onRemove__", data, object : MethodChannel.Result {
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
        invokeMethod("__onPopTo__", data, object : MethodChannel.Result {
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

    fun onNotify(url: String, index: Int, name: String, params: Any?) {
        val data = mapOf(
                "__event_name__" to "__onNotify__",
                "url" to url,
                "index" to index,
                "name" to name,
                "params" to params
        )
        Log.e("Thrio", "onNotify channel data $data")
        sink?.success(data)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        Log.e("Thrio", "onListen arguments $arguments events $events")
    }

    override fun onCancel(arguments: Any?) {
        Log.e("Thrio", "onCancel arguments $arguments")
    }
}