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
import io.flutter.plugin.common.BinaryMessenger
import java.lang.ref.WeakReference

internal class PageObserverChannel constructor(
    engine: FlutterEngine,
    messenger: BinaryMessenger
) : PageObserver, FlutterEngineIdentifier {
    val engine = WeakReference(engine)

    val channel: ThrioChannel = ThrioChannel(
        engine, "__thrio_page_channel__$entrypoint"
    )

    override val entrypoint
        get() = engine.get()?.entrypoint ?: NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
    override val pageId get() = engine.get()?.pageId ?: NAVIGATION_ROUTE_PAGE_ID_NONE

    init {
        channel.setupMethodChannel(messenger)
        on("willAppear")
        on("didAppear")
        on("willDisappear")
        on("didDisappear")
    }

    private fun on(method: String) {
        channel.registryMethod(method) { arguments, _ ->
            if (arguments == null) return@registryMethod
            val routeSettings = RouteSettings.fromArguments(arguments) ?: return@registryMethod
            val routeTypeString = arguments["routeType"] as String

            when (method) {
                "willAppear" -> PageRoutes.willAppear(
                    routeSettings,
                    RouteType.from(routeTypeString)
                )
                "didAppear" -> PageRoutes.didAppear(
                    routeSettings,
                    RouteType.from(routeTypeString)
                )
                "willDisappear" -> PageRoutes.willDisappear(
                    routeSettings,
                    RouteType.from(routeTypeString)
                )
                "didDisappear" -> PageRoutes.didDisappear(
                    routeSettings,
                    RouteType.from(routeTypeString)
                )
            }
        }
    }

    override fun willAppear(routeSettings: RouteSettings) {
        val arguments = routeSettings.toArgumentsWithParams(null)
        channel.invokeMethod("willAppear", arguments)
    }

    override fun didAppear(routeSettings: RouteSettings) {
        val arguments = routeSettings.toArgumentsWithParams(null)
        channel.invokeMethod("didAppear", arguments)
    }

    override fun willDisappear(routeSettings: RouteSettings) {
        val arguments = routeSettings.toArgumentsWithParams(null)
        channel.invokeMethod("willDisappear", arguments)
    }

    override fun didDisappear(routeSettings: RouteSettings) {
        val arguments = routeSettings.toArgumentsWithParams(null)
        channel.invokeMethod("didDisappear", arguments)
    }
}