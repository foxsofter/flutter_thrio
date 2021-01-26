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

import android.content.Context
import com.hellobike.flutter.thrio.channel.ThrioChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterMain

data class FlutterEngine(private val context: Context,
                         private val entrypoint: String,
                         private val readyListener: EngineReadyListener? = null) {
    val flutterEngine = FlutterEngine(context)
    internal var sendChannel: RouteSendChannel private set
    private var receiveChannel: RouteReceiveChannel
    internal var routeChannel: RouteObserverChannel
    internal var pageChannel: PageObserverChannel

    val isReady get() = receiveChannel.isReady

    init {
        val channel = ThrioChannel(entrypoint, "__thrio_app__${entrypoint}")
        channel.setupMethodChannel(flutterEngine.dartExecutor)
        channel.setupEventChannel(flutterEngine.dartExecutor)
        sendChannel = RouteSendChannel(channel)
        receiveChannel = RouteReceiveChannel(channel, readyListener)
        routeChannel = RouteObserverChannel(entrypoint, flutterEngine.dartExecutor)
        pageChannel = PageObserverChannel(entrypoint, flutterEngine.dartExecutor)

        val dartEntrypoint = DartExecutor.DartEntrypoint(FlutterMain.findAppBundlePath(), entrypoint)
        flutterEngine.dartExecutor.executeDartEntrypoint(dartEntrypoint)

        FlutterEngineCache.getInstance().put(entrypoint, flutterEngine)
    }

    fun addReadyListener(readyListener: EngineReadyListener?) {
        receiveChannel.addReadyListener(readyListener)
    }

    companion object {
        private const val TAG = "FlutterEngine"
    }
}