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

internal class RouteReceiveChannel(val channel: ThrioChannel,
                                   var readyListener: EngineReadyListener? = null) {

    var isReady = false
        private set

    private val readyLock = Any()

    private var readyListenerSet: MutableSet<EngineReadyListener>? = mutableSetOf()

    init {
        onReady()
        onPush()
        onNotify()
        onPop()
        onPopTo()
        onRemove()

        onLastRoute()
        onGetAllRoutes()

        onSetPopDisabled()
        onHotRestart()
        onRegisterUrls()
        onUnregisterUrls()
    }

    fun addReadyListener(readyListener: EngineReadyListener?) {
        if (readyListener == null) return
        if (isReady) {
            readyListener.onReady(channel.entrypoint)
        } else {
            synchronized(readyLock) {
                if (isReady) {
                    readyListener.onReady(channel.entrypoint)
                } else {
                    readyListenerSet?.add(readyListener)
                }
            }
        }
    }

    private fun onReady() {
        addReadyListener(readyListener)
        channel.registryMethod("ready") { _, _ ->
            synchronized(readyLock) {
                isReady = true
                readyListenerSet?.forEach { it.onReady(channel.entrypoint) }
                readyListenerSet = null
            }
        }
    }

    private fun onPush() {
        channel.registryMethod("push") { arguments, result ->
            if (arguments == null) return@registryMethod
            val url = arguments["url"] as String
            val params = arguments["params"]
            val animated = if (arguments["animated"] != null) arguments["animated"] as Boolean else true
            NavigationController.Push.push(url, params, animated, channel.entrypoint, result = result)
        }
    }

    private fun onNotify() {
        channel.registryMethod("notify") { arguments, result ->
            if (arguments == null) return@registryMethod
            val url = if (arguments["url"] != null) arguments["url"] as String else null
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val name = arguments["name"] as String
            val params = arguments["params"]
            NavigationController.Notify.notify(url, index, name, params) {
                result(it)
            }
        }
    }

    private fun onPop() {
        channel.registryMethod("pop") { arguments, result ->
            if (arguments == null) return@registryMethod
            val params = arguments["params"]
            val animated = if (arguments["animated"] != null) arguments["animated"] as Boolean else true
            NavigationController.Pop.pop(params, animated, result)
        }
    }

    private fun onPopTo() {
        channel.registryMethod("popTo") { arguments, result ->
            if (arguments == null) return@registryMethod
            val url = arguments["url"] as String
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val animated = if (arguments["animated"] != null) arguments["animated"] as Boolean else true
            NavigationController.PopTo.popTo(url, index, animated, result)
        }
    }

    private fun onRemove() {
        channel.registryMethod("remove") { arguments, result ->
            if (arguments == null) return@registryMethod
            val url = arguments["url"] as String
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val animated = if (arguments["animated"] != null) arguments["animated"] as Boolean else true
            NavigationController.Remove.remove(url, index, animated, result)
        }
    }

    private fun onLastRoute() {
        channel.registryMethod("lastRoute") { arguments, result ->
            if (arguments == null) return@registryMethod
            val url = if (arguments["url"] != null) arguments["url"] as String else null
            val route = ThrioNavigator.lastRoute(url)
            result(route?.settings?.name)
        }
    }

    private fun onGetAllRoutes() {
        channel.registryMethod("allRoutes") { arguments, result ->
            if (arguments == null) return@registryMethod
            val url = if (arguments["url"] != null) arguments["url"] as String else null
            val routes = ThrioNavigator.allRoutes(url)
            val routeNames = routes.map { it.settings.name }
            result(routeNames)
        }
    }

    private fun onSetPopDisabled() {
        channel.registryMethod("setPopDisabled") { _, _ -> }
    }

    private fun onHotRestart() {
        channel.registryMethod("hotRestart") { _, _ -> }
    }

    private fun onRegisterUrls() {
        channel.registryMethod("registerUrls") { _, _ -> }
    }

    private fun onUnregisterUrls() {
        channel.registryMethod("unregisterUrls") { _, _ -> }
    }

}
