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

import com.hellobike.flutter.thrio.channel.ThrioChannel
import io.flutter.plugin.common.BinaryMessenger

class RouteObserverChannel constructor(entrypoint: String, messenger: BinaryMessenger) : RouteObserver {

    private val channel: ThrioChannel = ThrioChannel(entrypoint, "__thrio_route_channel__$entrypoint")

    init {
        channel.setupMethodChannel(messenger)
        on("didPush")
        on("didPop")
        on("didPopTo")
        on("didRemove")
    }

    override fun didPush(routeSettings: RouteSettings) {
        channel.invokeMethod("didPush", routeSettings.toArguments())
    }

    override fun didPop(routeSettings: RouteSettings) {
        channel.invokeMethod("didPop", routeSettings.toArguments())
    }

    override fun didPopTo(routeSettings: RouteSettings) {
        channel.invokeMethod("didPopTo", routeSettings.toArguments())
    }

    override fun didRemove(routeSettings: RouteSettings) {
        channel.invokeMethod("didRemove", routeSettings.toArguments())
    }

    private fun on(method: String) {
        channel.registryMethod(method) { arguments, _ ->
            if (arguments == null) return@registryMethod
            val routeArguments = arguments["route"] ?: return@registryMethod
            val routeSettings = RouteSettings.fromArguments(routeArguments as Map<String, Any?>)
                    ?: return@registryMethod
            val previousRouteArguments = arguments["previousRoute"]
            val previousRouteSettings = if (previousRouteArguments == null) null else {
                RouteSettings.fromArguments(previousRouteArguments as Map<String, Any?>)
            }
            when (method) {
                "didPush" -> RouteObservers.didPush(routeSettings)
                "didPop" -> RouteObservers.didPop(routeSettings)
                "didPopTo" -> RouteObservers.didPopTo(routeSettings)
                "didRemove" -> RouteObservers.didRemove(routeSettings)
            }
        }
    }
}
