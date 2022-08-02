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

package com.foxsofter.flutter_thrio.navigator

import android.content.Context
import com.foxsofter.flutter_thrio.channel.ThrioChannel
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader

data class FlutterEngine(
    private val context: Context,
    private val entrypoint: String,
    private val readyListener: EngineReadyListener? = null
) {
    private val engine = FlutterEngine(context)
    internal var sendChannel: RouteSendChannel private set
    private val receiveChannel: RouteReceiveChannel
    internal val routeChannel: RouteObserverChannel
    internal val pageChannel: PageObserverChannel
    internal val moduleContextChannel: ThrioChannel

    init {
        val channel = ThrioChannel(entrypoint, "__thrio_app__${entrypoint}")
        channel.setupMethodChannel(engine.dartExecutor)
        channel.setupEventChannel(engine.dartExecutor)
        sendChannel = RouteSendChannel(channel)
        receiveChannel = RouteReceiveChannel(channel, readyListener)
        routeChannel = RouteObserverChannel(entrypoint, engine.dartExecutor)
        pageChannel = PageObserverChannel(entrypoint, engine.dartExecutor)
        moduleContextChannel = ThrioChannel(
            entrypoint,
            "__thrio_module_context__${entrypoint}"
        )
        moduleContextChannel.setupMethodChannel(engine.dartExecutor)

        val dartEntrypoint =
            DartExecutor.DartEntrypoint(FlutterInjector.instance().flutterLoader().findAppBundlePath(), entrypoint)
        engine.dartExecutor.executeDartEntrypoint(dartEntrypoint)

        FlutterEngineCache.getInstance().put(entrypoint, engine)
    }

    companion object {
        private const val TAG = "FlutterEngine"
    }
}