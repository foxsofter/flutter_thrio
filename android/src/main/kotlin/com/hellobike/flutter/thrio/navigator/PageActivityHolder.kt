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

import android.app.Activity
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableIntCallback
import io.flutter.embedding.android.ThrioActivity
import java.lang.ref.WeakReference

internal data class PageActivityHolder(val pageId: Int) {

    private val routes by lazy { mutableListOf<PageRoute>() }

    var activity: WeakReference<out Activity>? = null

    fun hasRoute(url: String? = null, index: Int? = null): Boolean = when (url) {
        null -> routes.isNotEmpty()
        else -> routes.any {
            it.settings.url == url && (index == null || index == 0 || it.settings.index == index)
        }
    }

    fun lastRoute(url: String? = null, index: Int? = null): PageRoute? = when (url) {
        null -> routes.lastOrNull()
        else -> routes.lastOrNull {
            it.settings.url == url && (index == null || index == 0 || it.settings.index == index)
        }
    }

    fun allRoute(url: String): List<PageRoute> = routes.takeWhile { it.settings.url == url }

    fun push(route: PageRoute, result: NullableIntCallback) =
            activity?.get()?.let { activity ->
                if (activity is ThrioActivity) {
                    activity.onPush(route.settings.toArguments()) {
                        if (it) {
                            routes.add(route)
                            result(route.settings.index)
                        } else {
                            result(null)
                        }
                    }
                } else {
                    routes.add(route)
                    result(route.settings.index)
                }
            }

    fun notify(url: String, index: Int?, name: String, params: Any?, result: BooleanCallback) {
        var isMatch = false
        routes.forEach {
            if (it.settings.url == url
                    && (index == null || index == 0 || it.settings.index == index)) {
                isMatch = true
                it.addNotify(name, params)
            }
        }
        result(isMatch)
    }


    fun pop(params: Any?, animated: Boolean, result: BooleanCallback) {
        val lastRoute = lastRoute()
        if (lastRoute == null) {
            result(false)
            return
        }

        activity?.get()?.let { activity ->
            if (activity is ThrioActivity) {
                lastRoute.settings.params = params
                lastRoute.settings.animated = animated
                activity.onPop(lastRoute.settings.toArguments()) { it ->
                    if (it) {
                        routes.remove(lastRoute)
                    }
                    result(it)
                    if (it) {
                        lastRoute.poppedResult?.invoke(params)
                        lastRoute.poppedResult = null
                        if (lastRoute.entryPoint != lastRoute.fromEntryPoint) {
                            FlutterEngineFactory.getEngine(lastRoute.fromEntryPoint)?.onPop(lastRoute.settings.toArguments()) {}
                        }
                    }
                }
            } else {
                routes.remove(lastRoute)
                result(true)
                lastRoute.poppedResult?.invoke(params)
            }
        }
        result(false)
    }

    fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val route = lastRoute(url, index)
        if (route == null) {
            result(false)
            return
        }

        activity?.get()?.let { activity ->
            if (activity is ThrioActivity) {
                activity.onPop(route.settings.toArguments()) {
                    if (it) {
                        val lastIndex = routes.indexOf(route)
                        for (i in routes.size downTo lastIndex + 1) {
                            routes.removeAt(i)
                        }
                    }
                    result(it)
                }
            } else {
                result(true)
            }
        }
        result(false)
    }

    fun remove(url: String, index: Int?, result: BooleanCallback) {
        val route = lastRoute(url, index)
        if (route == null) {
            result(false)
            return
        }

        activity?.get()?.let { activity ->
            if (activity is ThrioActivity) {
                activity.onRemove(route.settings.toArguments()) {
                    if (it) {
                        routes.remove(route)
                    }
                    result(it)
                }
            } else {
                routes.remove(route)
                result(true)
            }
        }
        result(false)
    }
}