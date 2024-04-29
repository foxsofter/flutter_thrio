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

import com.foxsofter.flutter_thrio.VoidCallback
import com.foxsofter.flutter_thrio.channel.ThrioChannel

internal class RouteReceiveChannel(
    private val channel: ThrioChannel,
    private var onReady: VoidCallback? = null
) {
    init {
        onReady()
        onPush()
        onNotify()
        onMaybePop()
        onPop()
        onPopFlutter()
        onPopTo()
        onRemove()
        onReplace()
        onCanPop()

        onLastRoute()
        onGetAllRoutes()
        onIsInitialRoute()

        onSetPopDisabled()
        onHotRestart()
    }

    private fun onReady() {
        channel.registryMethod("ready") { _, _ ->
            onReady?.invoke()
            onReady = null
        }
    }

    private fun onPush() {
        channel.registryMethod("push") { arguments, result ->
            if (arguments == null) {
                result(null)
                return@registryMethod
            }
            val url = arguments["url"] as String
            val params = arguments["params"]
            val animated = arguments["animated"] == true
            val fromURL = arguments["fromURL"] as String?
            val prevURL = arguments["prevURL"] as String?
            val innerURL = arguments["innerURL"] as String?
            NavigationController.Push.push(
                url,
                params,
                animated,
                channel.entrypoint,
                fromURL,
                prevURL,
                innerURL,
            ) {
                result(it)
            }
        }
    }

    private fun onNotify() {
        channel.registryMethod("notify") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val url = if (arguments["url"] != null) arguments["url"] as String else null
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val name = arguments["name"] as String
            val params = arguments["params"]
            NavigationController.Notify.notify(url, index, name, params) {
                result(it)
            }
        }
    }

    private fun onMaybePop() {
        channel.registryMethod("maybePop") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val params = arguments["params"]
            val animated = arguments["animated"] == true
            NavigationController.Pop.maybePop(params, animated) {
                result(it)
            }
        }
    }

    private fun onPop() {
        channel.registryMethod("pop") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val params = arguments["params"]
            val animated = arguments["animated"] == true
            NavigationController.Pop.pop(params, animated) {
                result(it)
            }
        }
    }

    private fun onPopFlutter() {
        channel.registryMethod("popFlutter") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val params = arguments["params"]
            val animated = arguments["animated"] == true
            NavigationController.Pop.popFlutter(params, animated) {
                result(it)
            }
        }
    }

    private fun onPopTo() {
        channel.registryMethod("popTo") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val url = arguments["url"] as String
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val animated = arguments["animated"] == true
            NavigationController.PopTo.popTo(url, index, animated) {
                result(it)
            }
        }
    }

    private fun onRemove() {
        channel.registryMethod("remove") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val url = arguments["url"] as String
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val animated = arguments["animated"] == true
            NavigationController.Remove.remove(url, index, animated) {
                result(it)
            }
        }
    }

    private fun onReplace() {
        channel.registryMethod("replace") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val url = arguments["url"] as String
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val newUrl = arguments["newUrl"] as String
            NavigationController.Replace.replace(url, index, newUrl) {
                result(it)
            }
        }
    }

    private fun onCanPop() {
        channel.registryMethod("canPop") { _, result ->
            NavigationController.Pop.canPop {
                result(it)
            }
        }
    }

    private fun onLastRoute() {
        channel.registryMethod("lastRoute") { arguments, result ->
            if (arguments == null) {
                result(null)
                return@registryMethod
            }
            val url = if (arguments["url"] != null) arguments["url"] as String else null
            val route = ThrioNavigator.lastRoute(url)
            result(route?.settings?.name)
        }
    }

    private fun onGetAllRoutes() {
        channel.registryMethod("allRoutes") { arguments, result ->
            if (arguments == null) {
                result(listOf<String>())
                return@registryMethod
            }
            val url = if (arguments["url"] != null) arguments["url"] as String else null
            val routes = ThrioNavigator.allRoutes(url)
            val routeNames = routes.map { it.settings.name }
            result(routeNames)
        }
    }

    private fun onIsInitialRoute() {
        channel.registryMethod("isInitialRoute") { arguments, result ->
            if (arguments == null) {
                result(false)
                return@registryMethod
            }
            val url = arguments["url"] as String
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            result(NavigationController.isInitialRoute(url, index))
        }
    }

    private fun onSetPopDisabled() {
        channel.registryMethod("setPopDisabled") { _, result -> result(null) }
    }

    private fun onHotRestart() {
        channel.registryMethod("hotRestart") { _, result ->
            NavigationController.hotRestart()
            result(null)
        }
    }

}
