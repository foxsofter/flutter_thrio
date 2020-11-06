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

class PageObserverChannel constructor(entrypoint: String, messenger: BinaryMessenger) {

    private val channel: ThrioChannel = ThrioChannel(entrypoint, "__thrio_page_channel__$entrypoint")

    init {
        channel.setupMethodChannel(messenger)
        on("onCreate")
        on("willAppear")
        on("didAppear")
        on("willDisappear")
        on("didDisappear")
    }

    private fun on(method: String) {
        channel.registryMethod(method) { arguments, _ ->
            if (arguments == null) return@registryMethod
            val routeSettings = RouteSettings.fromArguments(arguments) ?: return@registryMethod
            when (method) {
                "onCreate" -> PageObservers.onCreate(routeSettings)
                "willAppear" -> PageObservers.willAppear(routeSettings)
                "didAppear" -> PageObservers.didAppear(routeSettings)
                "willDisappear" -> PageObservers.willDisappear(routeSettings)
                "didDisappear" -> PageObservers.didDisappear(routeSettings)
            }
        }
    }
}