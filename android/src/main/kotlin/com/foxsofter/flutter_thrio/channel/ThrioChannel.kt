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

package com.foxsofter.flutter_thrio.channel

import com.foxsofter.flutter_thrio.EventHandler
import com.foxsofter.flutter_thrio.MethodHandler
import com.foxsofter.flutter_thrio.NullableAnyCallback
import com.foxsofter.flutter_thrio.VoidCallback
import com.foxsofter.flutter_thrio.exception.ThrioException
import com.foxsofter.flutter_thrio.navigator.FlutterEngineFactory
import com.foxsofter.flutter_thrio.navigator.Log
import com.foxsofter.flutter_thrio.navigator.NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
import com.foxsofter.flutter_thrio.registry.RegistryMap
import com.foxsofter.flutter_thrio.registry.RegistrySetMap
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

open class ThrioChannel constructor(
    val entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT,
    private val channelName: String = "__thrio__"
) {

    init {
        if (FlutterEngineFactory.isMultiEngineEnabled && entrypoint == NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT) {
            throw ThrioException("multi-engine mode, entrypoint should not be main.")
        }
    }

    private var methodChannel: MethodChannel? = null

    private var eventChannel: EventChannel? = null

    private var streamHandler: EventStreamHandler? = null

    private val methodHandlers = RegistryMap<String, MethodHandler>()

    private val eventHandlers = RegistrySetMap<String, EventHandler>()

    fun setupMethodChannel(messenger: BinaryMessenger) {
        val methodChannelName = "_method_$channelName"
        methodChannel = MethodChannel(messenger, methodChannelName)
        methodChannel?.setMethodCallHandler { call, result ->
            val methodHandler = methodHandlers[call.method]
            if (methodHandler == null) {
                result.notImplemented()
            } else {
                try {
                    @Suppress("UNCHECKED_CAST")
                    val args =
                        if (call.arguments == null) null else call.arguments as Map<String, Any?>
                    methodHandler.invoke(args) {
                        result.success(it)
                    }
                } catch (e: Exception) {
                    result.error("", e.message, e.localizedMessage)
                }
            }
        }
    }

    @JvmOverloads
    fun invokeMethod(
        method: String,
        arguments: Map<String, Any?>? = null,
        callback: NullableAnyCallback? = null
    ) {
        methodChannel?.invokeMethod(method, arguments, object : MethodChannel.Result {
            override fun success(value: Any?) {
                callback?.invoke(value)
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
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
        val eventChannelName = "_event_$channelName"
        eventChannel = EventChannel(messenger, eventChannelName)
        streamHandler = EventStreamHandler()
        eventChannel?.setStreamHandler(streamHandler)
    }

    fun sendEvent(name: String, arguments: Map<String, Any?>?) {
        var args = arguments?.toMutableMap()?.also { it["__event_name__"] = name }
            ?: mapOf<String, Any>("__event_name__" to name)
        streamHandler?.sink?.success(args)
    }

    fun registryEvent(name: String, handler: EventHandler): VoidCallback {
        return eventHandlers.registry(name, handler)
    }

    class EventStreamHandler : EventChannel.StreamHandler {
        var sink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            sink = events
            Log.v("Thrio", "onListen arguments $arguments events $events")
        }

        override fun onCancel(arguments: Any?) {
            Log.v("Thrio", "onCancel arguments $arguments")
        }
    }
}