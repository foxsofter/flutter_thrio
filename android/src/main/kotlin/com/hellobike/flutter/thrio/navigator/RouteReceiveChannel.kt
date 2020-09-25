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

class RouteReceiveChannel(private val channel: ThrioChannel,
                          private var readyListener: EngineReadyListener? = null) {
    init {
        onReady()
        onPush()
        onNotify()
        onPop()
        onPopTo()
        onRemove()
    }

    private fun onReady() {
        channel.registryMethod("onReady") { _, _ ->
            readyListener?.onReady(channel.entrypoint)
            readyListener = null
        }
    }

    private fun onPush() {
        channel.registryMethod("onPush") { arguments, result ->
            val url = arguments["url"] as String
            val params = arguments["params"]
            val animated = arguments["animated"] as Boolean
            NavigationController.Push.push(url, params, animated, channel.entrypoint, result = result)
        }
    }

    private fun onNotify() {
        channel.registryMethod("onNotify") { arguments, result ->
            val url = arguments["url"] as String
            val index = arguments["index"] as Int
            val name = arguments["name"] as String
            val params = arguments["params"]
            NavigationController.Notify.notify(url, index, name, params, result)
        }
    }

    private fun onPop() {
        channel.registryMethod("onPop") { arguments, result ->
            val params = arguments["params"]
            val animated = arguments["animated"] as Boolean
            NavigationController.Pop.pop(params, animated, result)
        }
    }

    private fun onPopTo() {
        channel.registryMethod("onPop") { arguments, result ->
            val url = arguments["url"] as String
            val index = arguments["index"] as Int
            val animated = arguments["animated"] as Boolean
            NavigationController.PopTo.popTo(url, index, animated, result)
        }
    }

    private fun onRemove() {
        channel.registryMethod("onRemove") { arguments, result ->
            val url = arguments["url"] as String
            val index = arguments["index"] as Int
            val animated = arguments["animated"] as Boolean
            NavigationController.Remove.remove(url, index, animated, result)
        }
    }
}
