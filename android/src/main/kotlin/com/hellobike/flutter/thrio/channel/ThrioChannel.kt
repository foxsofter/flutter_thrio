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

package com.hellobike.flutter.thrio.channel

import com.hellobike.flutter.thrio.EventHandler
import com.hellobike.flutter.thrio.MethodHandler
import com.hellobike.flutter.thrio.NullableAnyCallback
import com.hellobike.flutter.thrio.VoidCallback
import com.hellobike.flutter.thrio.registry.RegistryMap
import com.hellobike.flutter.thrio.registry.RegistrySetMap
import io.flutter.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

open class ThrioChannel constructor(val entrypoint: String, private val channelName: String) {

    private var methodChannel: MethodChannel? = null

    private var eventChannel: EventChannel? = null

    private val methodHandlers = RegistryMap<String, MethodHandler>()

    private val eventHandlers = RegistrySetMap<String, EventHandler>()

    fun setupMethodChannel(messenger: BinaryMessenger) {
        val methodChannelName = "_method_${channelName}${entrypoint}"
        methodChannel = MethodChannel(messenger, methodChannelName)
        methodChannel?.setMethodCallHandler { call, result ->
            val methodHandler = methodHandlers[call.method]
            if (methodHandler == null) {
                result.notImplemented()
            } else {
                try {
                    methodHandler.invoke(call.arguments as Map<String, Any>) {
                        result.success(it)
                    }
                } catch (e: Exception) {
                    result.error("", e.message, e.localizedMessage)
                }
            }
        }
    }

    fun invokeMethod(method: String, arguments: Map<String, Any>?) {
        methodChannel?.invokeMethod(method, arguments)
    }

    fun invokeMethod(method: String, arguments: Map<String, Any>?, callback: NullableAnyCallback?) {
        methodChannel?.invokeMethod(method, arguments, object : MethodChannel.Result {
            override fun success(value: Any?) {
                callback?.invoke(value)
            }

            override fun error(errorCode: String?, errorMessage: String?, errorDetails: Any?) {
                Log.e("ThrioChannel", "call $method return error: $errorMessage")
            }

            override fun notImplemented() {
                Log.e("ThrioChannel", "call $method notImplemented")
            }
        })
    }

    fun registryMethod(method: String, handler: MethodHandler): VoidCallback {
        return methodHandlers.registry(method, handler)
    }

    fun setupEventChannel(messenger: BinaryMessenger) {
        val eventChannelName = "_event_${channelName}${entrypoint}"
        eventChannel = EventChannel(messenger, eventChannelName)
        eventChannel?.setStreamHandler(EventStreamHandler)
    }

    fun sendEvent(name: String, arguments: Map<String, Any>?) {
        var args = arguments?.toMutableMap()?.also { it["__event_name__"] = name }
                ?: mapOf<String, Any>("__event_name__" to name)
        EventStreamHandler.sink?.success(args)
    }

    fun registryEvent(name: String, handler: EventHandler): VoidCallback {
        return eventHandlers.registry(name, handler)
    }

    object EventStreamHandler : EventChannel.StreamHandler {
        var sink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            sink = events
            Log.i("Thrio", "onListen arguments $arguments events $events")
        }

        override fun onCancel(arguments: Any?) {
            Log.i("Thrio", "onCancel arguments $arguments")
        }
    }
}