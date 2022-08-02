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

object FlutterEngineFactory : PageObserver, RouteObserver {

    private val flutterEngines = mutableMapOf<String, FlutterEngine>()

    internal var isMultiEngineEnabled = false

    fun startup(
        context: Context,
        entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT,
        readyListener: EngineReadyListener? = null
    ) {
        val ep = if (!isMultiEngineEnabled)
            NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
        else
            entrypoint

        if (flutterEngines.contains(ep)) {
            readyListener?.onReady(ep)
        } else {
            flutterEngines[ep] = FlutterEngine(context, ep, readyListener)
        }
    }

    fun getEngine(entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT): FlutterEngine? {
        val ep = if (!isMultiEngineEnabled)
            NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
        else
            entrypoint
        return flutterEngines[ep]
    }

    fun setModuleContextValue(value: Any?, key: String) {
        val engines = flutterEngines.values;
        for (engine in engines) {
            engine.moduleContextChannel.invokeMethod("set", mutableMapOf(key to value))
        }
    }

    override fun willAppear(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.pageChannel.willAppear(routeSettings)
        }
    }

    override fun didAppear(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.pageChannel.didAppear(routeSettings)
        }
    }

    override fun willDisappear(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.pageChannel.willDisappear(routeSettings)
        }
    }

    override fun didDisappear(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.pageChannel.didDisappear(routeSettings)
        }
    }

    override fun didPush(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.routeChannel.didPush(routeSettings)
        }
    }

    override fun didPop(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.routeChannel.didPop(routeSettings)
        }
    }

    override fun didPopTo(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.routeChannel.didPopTo(routeSettings)
        }
    }

    override fun didRemove(routeSettings: RouteSettings) {
        flutterEngines.values.forEach { engine ->
            engine.routeChannel.didRemove(routeSettings)
        }
    }
}