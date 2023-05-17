/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 foxsofter
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

import com.foxsofter.flutter_thrio.channel.ThrioChannel
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.ThrioFlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor

data class FlutterEngine(
    override val entrypoint: String,
    val flutterEngine: ThrioFlutterEngine,
    private val readyListener: FlutterEngineReadyListener? = null
) : FlutterEngineIdentifier {
    override var pageId: Int = NAVIGATION_ROUTE_PAGE_ID_NONE

    internal var sendChannel: RouteSendChannel private set
    private val receiveChannel: RouteReceiveChannel
    internal val routeChannel: RouteObserverChannel
    internal val pageChannel: PageObserverChannel
    internal val moduleContextChannel: ThrioChannel

    init {
        val channel = ThrioChannel(
            this, "__thrio_app__${entrypoint}"
        )
        channel.setupMethodChannel(flutterEngine.dartExecutor)
        channel.setupEventChannel(flutterEngine.dartExecutor)
        sendChannel = RouteSendChannel(channel)
        receiveChannel = RouteReceiveChannel(channel) {
            readyListener?.onReady(this)
        }
        routeChannel = RouteObserverChannel(this, flutterEngine.dartExecutor)
        pageChannel = PageObserverChannel(this, flutterEngine.dartExecutor)
        moduleContextChannel = ThrioChannel(
            this,
            "__thrio_module_context__${entrypoint}"
        )
        moduleContextChannel.setupMethodChannel(flutterEngine.dartExecutor)

        val dartEntrypoint = DartExecutor.DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(), entrypoint
        )
        flutterEngine.dartExecutor.executeDartEntrypoint(dartEntrypoint)
    }

    fun destroy() {
        sendChannel.channel.destroy()
        routeChannel.channel.destroy()
        pageChannel.channel.destroy()
        moduleContextChannel.destroy()
    }
}