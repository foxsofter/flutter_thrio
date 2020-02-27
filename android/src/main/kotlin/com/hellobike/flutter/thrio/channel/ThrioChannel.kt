package com.hellobike.flutter.thrio.channel

import android.support.annotation.UiThread
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


internal class ThrioChannel constructor(messenger: BinaryMessenger, name: String) {

    private val methodProxy by lazy {
        MethodChannel(messenger, "_method_$name")
    }
    private val eventProxy by lazy {
        EventChannel(messenger, "_event_$name")
    }

    /**
     * Invokes a method on this channel, expecting no result.
     *
     * @param method the name String of the method.
     * @param arguments the arguments for the invocation, possibly null.
     */
    @UiThread
    fun invokeMethod(method: String, arguments: Any?) {
        methodProxy.invokeMethod(method, arguments)
    }

    /**
     * Invokes a method on this channel, optionally expecting a result.
     *
     *
     * Any uncaught exception thrown by the result callback will be caught and logged.
     *
     * @param method the name String of the method.
     * @param arguments the arguments for the invocation, possibly null.
     * @param callback a [Result] callback for the invocation result, or null.
     */
    @UiThread
    fun invokeMethod(method: String, arguments: Any?, callback: MethodChannel.Result?) {
        methodProxy.invokeMethod(method, arguments, callback)
    }

    /**
     * Registers a method call handler on this channel.
     *
     *
     * Overrides any existing handler registration for (the name of) this channel.
     *
     *
     * If no handler has been registered, any incoming method call on this channel will be handled
     * silently by sending a null reply. This results in a
     * [MissingPluginException](https://docs.flutter.io/flutter/services/MissingPluginException-class.html)
     * on the Dart side, unless an
     * [OptionalMethodChannel](https://docs.flutter.io/flutter/services/OptionalMethodChannel-class.html)
     * is used.
     *
     * @param handler a [MethodChannel.MethodCallHandler], or null to deregister.
     */
    @UiThread
    fun setMethodCallHandler(handler: MethodChannel.MethodCallHandler?) {
        methodProxy.setMethodCallHandler(handler)
    }

    /**
     * Adjusts the number of messages that will get buffered when sending messages to
     * channels that aren't fully setup yet.  For example, the engine isn't running
     * yet or the channel's message handler isn't setup on the Dart side yet.
     */
    fun resizeChannelBuffer(newSize: Int) {
        methodProxy.resizeChannelBuffer(newSize)
    }

    /**
     * Registers a stream handler on this channel.
     *
     *
     * Overrides any existing handler registration for (the name of) this channel.
     *
     *
     * If no handler has been registered, any incoming stream setup requests will be handled
     * silently by providing an empty stream.
     *
     * @param handler a [EventChannel.StreamHandler], or null to deregister.
     */
    @UiThread
    fun setStreamHandler(handler: EventChannel.StreamHandler?) {
        eventProxy.setStreamHandler(handler)
    }
}