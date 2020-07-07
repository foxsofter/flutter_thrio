/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Hellobike Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

package com.hellobike.flutter.thrio.navigator

import android.util.Log
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.channel.ThrioChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class RouteSendChannel constructor(messenger: BinaryMessenger, val entrypoint: String)
    : ThrioChannel(messenger, "__thrio_app__"),
        RouteSendHandler,
        EventChannel.StreamHandler {

    init {
        setStreamHandler(this)
    }

    private var sink: EventChannel.EventSink? = null

    override fun onPush(arguments: Any?, result: BooleanCallback) {
        invokeMethod("__onPush__", arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                Log.e("Thrio", "onPush error: $errorMessage")
            }

            override fun notImplemented() {}
        })
    }

    override fun onNotify(arguments: Any?, result: BooleanCallback) {
        Log.e("Thrio", "onNotify channel data $arguments")
        sink?.success(arguments)
    }

    override fun onPop(arguments: Any?, result: BooleanCallback) {
        invokeMethod("__onPop__", arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                Log.e("Thrio", "onPop error: $errorMessage")
            }

            override fun notImplemented() {}
        })
    }

    override fun onPopTo(arguments: Any?, result: BooleanCallback) {
        invokeMethod("__onPopTo__", arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                Log.e("Thrio", "onPopTo error: $errorMessage")
            }

            override fun notImplemented() {}
        })
    }

    override fun onRemove(arguments: Any?, result: BooleanCallback) {
        invokeMethod("__onRemove__", arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                if (result !is Boolean) {
                    return
                }
                result(result)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                Log.e("Thrio", "onRemove error: $errorMessage")
            }

            override fun notImplemented() {}
        })
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        Log.e("Thrio", "onListen arguments $arguments events $events")
    }

    override fun onCancel(arguments: Any?) {
        Log.e("Thrio", "onCancel arguments $arguments")
    }
}