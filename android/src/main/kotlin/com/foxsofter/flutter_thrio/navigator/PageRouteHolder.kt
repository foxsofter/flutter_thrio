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

import android.app.Activity
import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.IntCallback
import com.foxsofter.flutter_thrio.NullableIntCallback
import com.foxsofter.flutter_thrio.module.ModuleIntentBuilders
import com.foxsofter.flutter_thrio.module.ModuleJsonDeserializers
import com.foxsofter.flutter_thrio.module.ModuleJsonSerializers
import com.foxsofter.flutter_thrio.module.ModuleRouteObservers
import io.flutter.embedding.android.ThrioFlutterActivityBase
import java.lang.ref.WeakReference

internal data class PageRouteHolder(
    val pageId: Int,
    val clazz: Class<out Activity>,
    val entrypoint: String = NAVIGATION_NATIVE_ENTRYPOINT
) {
    internal val routes by lazy { mutableListOf<PageRoute>() }

    var activity: WeakReference<out Activity>? = null

    fun hasRoute(url: String? = null, index: Int? = null): Boolean = when (url) {
        null -> routes.isNotEmpty()
        else -> routes.any {
            it.settings.url == url && (index == null || index == 0 || it.settings.index == index)
        }
    }

    fun firstRoute(url: String? = null, index: Int? = null): PageRoute? = when (url) {
        null -> routes.firstOrNull()
        else -> routes.firstOrNull {
            it.settings.url == url && (index == null || index == 0 || it.settings.index == index)
        }
    }

    fun lastRoute(url: String? = null, index: Int? = null): PageRoute? = when (url) {
        null -> routes.lastOrNull()
        else -> routes.lastOrNull {
            it.settings.url == url && (index == null || index == 0 || it.settings.index == index)
        }
    }

    fun lastRoute(entrypoint: String): PageRoute? =
        routes.lastOrNull { it.entrypoint == entrypoint }

    fun allRoute(url: String? = null): List<PageRoute> = when (url) {
        null -> routes
        else -> routes.filter { it.settings.url == url }
    }

    fun push(route: PageRoute, result: NullableIntCallback) {
        val activity = activity?.get()
        if (activity != null) {
            if (activity is ThrioFlutterActivityBase) {
                route.settings.params = ModuleJsonSerializers.serializeParams(route.settings.params)
                activity.onPush(route.settings.toArguments()) { r ->
                    if (r) {
                        routes.add(route)
                        result(route.settings.index)
                    } else {
                        result(null)
                    }
                    PageRoutes.lastRoute = PageRoutes.lastRoute()
                }
            } else {
                routes.add(route)
                result(route.settings.index)
                ModuleRouteObservers.didPush(route.settings)
                PageRoutes.lastRoute = route
            }
        } else {
            result(null)
        }
    }

    fun <T> notify(url: String?, index: Int?, name: String, params: T?, result: BooleanCallback) {
        var isMatch = false
        routes.forEach { route ->
            if ((url == null || route.settings.url == url) &&
                (index == null || index == 0 || route.settings.index == index)
            ) {
                isMatch = true
                route.addNotify<T>(name, params)
            }
        }
        result(isMatch)
    }

    fun <T> maybePop(
        params: T?,
        animated: Boolean,
        inRoot: Boolean = false,
        result: IntCallback
    ) {
        val lastRoute = lastRoute()
        if (lastRoute == null) {
            result(0)
            return
        }
        val activity = activity?.get()
        if (activity != null && !activity.isDestroyed) {
            if (activity is ThrioFlutterActivityBase) {
                lastRoute.settings.params = ModuleJsonSerializers.serializeParams(params)
                lastRoute.settings.animated = animated
                var arguments = lastRoute.settings.toArguments()
                arguments = mutableMapOf<String, Any?>().also { args ->
                    args.putAll(arguments)
                    args["inRoot"] = inRoot
                }
                activity.onMaybePop(arguments, result)
            } else {
                result(1)
            }
        } else {
            result(0)
        }
    }

    fun <T> pop(
        params: T?,
        animated: Boolean,
        inRoot: Boolean = false,
        result: BooleanCallback
    ) {
        val lastRoute = lastRoute()
        if (lastRoute == null) {
            result(false)
            return
        }
        val activity = activity?.get()
        if (activity != null && !activity.isDestroyed) {
            if (activity is ThrioFlutterActivityBase) {
                lastRoute.settings.params = ModuleJsonSerializers.serializeParams(params)
                lastRoute.settings.animated = animated
                var arguments = lastRoute.settings.toArguments()
                arguments = mutableMapOf<String, Any?>().also { args ->
                    args.putAll(arguments)
                    args["inRoot"] = inRoot
                }
                activity.onPop(arguments) { r ->
                    if (r) {
                        routes.remove(lastRoute)
                    }
                    result(r)
                    if (r) {
                        lastRoute.poppedResult?.let { poppedCallback ->
                            poppedCallback(ModuleJsonDeserializers.deserializeParams(params))
                        }
                        lastRoute.poppedResult = null
                        if (lastRoute.fromEntrypoint != NAVIGATION_NATIVE_ENTRYPOINT &&
                            lastRoute.entrypoint != lastRoute.fromEntrypoint
                        ) {
                            FlutterEngineFactory.getEngine(
                                lastRoute.fromPageId,
                                lastRoute.fromEntrypoint
                            )?.sendChannel?.onPop(
                                lastRoute.settings.toArguments()
                            ) {}
                        }
                    }
                    PageRoutes.lastRoute = PageRoutes.lastRoute()
                }
            } else {
                routes.remove(lastRoute)
                result(true)
                lastRoute.poppedResult?.let { callback ->
                    callback(ModuleJsonDeserializers.deserializeParams(params))
                }
                lastRoute.poppedResult = null
                if (lastRoute.fromEntrypoint != NAVIGATION_NATIVE_ENTRYPOINT) {
                    lastRoute.settings.params = ModuleJsonSerializers.serializeParams(params)
                    lastRoute.settings.animated = false
                    FlutterEngineFactory.getEngine(
                        lastRoute.fromPageId,
                        lastRoute.fromEntrypoint
                    )?.sendChannel?.onPop(
                        lastRoute.settings.toArguments()
                    ) {}
                }
                ModuleRouteObservers.didPop(lastRoute.settings)
                PageRoutes.lastRoute = PageRoutes.lastRoute()
            }
        } else {
            result(false)
            lastRoute.poppedResult = null
        }
    }

    fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val route = lastRoute(url, index)
        if (route == null) {
            result(false)
            return
        }

        route.settings.animated = animated

        val activity = activity?.get()
        if (activity != null) {
            if (activity is ThrioFlutterActivityBase) {
                activity.onPopTo(route.settings.toArguments()) { r ->
                    if (r) {
                        val lastIndex = routes.indexOf(route)
                        for (i in routes.size - 1 downTo lastIndex + 1) {
                            routes.removeAt(i)
                        }
                    }
                    result(r)
                    PageRoutes.lastRoute = PageRoutes.lastRoute()
                }
            } else {
                result(true)
                ModuleRouteObservers.didPopTo(route.settings)
                PageRoutes.lastRoute = route
            }
        } else {
            result(false)
        }
    }

    fun remove(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val route = lastRoute(url, index)
        if (route == null) {
            result(false)
            return
        }

        route.settings.animated = animated

        val activity = activity?.get()
        if (activity != null) {
            if (activity is ThrioFlutterActivityBase) {
                activity.onRemove(route.settings.toArguments()) {
                    if (it) {
                        routes.remove(route)
                    }
                    result(it)
                    PageRoutes.lastRoute = PageRoutes.lastRoute()
                }
            } else {
                routes.remove(route)
                result(true)
                ModuleRouteObservers.didRemove(route.settings)
                PageRoutes.lastRoute = PageRoutes.lastRoute()
            }
        } else {
            result(false)
        }
    }

    fun replace(
        url: String,
        index: Int?,
        newUrl: String,
        newIndex: Int,
        result: NullableIntCallback
    ) {
        val oldRoute = lastRoute(url, index)
        val lastRoute = PageRoutes.lastRoute(newUrl)
        // 现阶段只实现 Flutter 页面之间的 replace 操作
        val clz = ModuleIntentBuilders.flutterIntentBuilder.getActivityClz()
        if (oldRoute != null && clz.isAssignableFrom(oldRoute.clazz) &&
            (lastRoute == null || clz.isAssignableFrom(lastRoute.clazz))
        ) {
            val activity = activity?.get()
            if (activity != null && activity is ThrioFlutterActivityBase) {
                val args = oldRoute.settings.toArgumentsWith(newUrl, newIndex)
                activity.onReplace(args) {
                    if (it) {
                        val newRouteSettings = RouteSettings(newUrl, newIndex)
                        newRouteSettings.isNested = oldRoute.settings.isNested
                        oldRoute.settings = newRouteSettings
                        oldRoute.settings.params = null
                        // 清除通知
                        oldRoute.removeNotify()
                        // 更新 intent 避免引起数据错误
                        val settingData = hashMapOf<String, Any?>().also { map ->
                            map.putAll(newRouteSettings.toArguments())
                        }
                        activity.intent.putExtra(NAVIGATION_ROUTE_SETTINGS_KEY, settingData)
                    }
                    result(if (it) newIndex else null)
                }
            } else {
                result(null)
            }
        } else {
            result(null)
        }
    }

    fun canPop(
        inRoot: Boolean = false,
        result: BooleanCallback?
    ) {
        val lastRoute = lastRoute()
        if (lastRoute == null) {
            result?.invoke(false)
            return
        }
        if (inRoot) {
            val firstRoute = firstRoute()
            if (lastRoute == firstRoute) {
                result?.invoke(false)
                return
            }
        }
        val activity = activity?.get()
        if (activity == null) {
            result?.invoke(false)
            return
        }
        if (activity is ThrioFlutterActivityBase) {
            var arguments = lastRoute.settings.toArguments()
            arguments = mutableMapOf<String, Any?>().also { args ->
                args.putAll(arguments)
                args["inRoot"] = inRoot
            }
            activity.onCanPop(arguments){
                result?.invoke(it)
            }
        } else {
            result?.invoke(true)
        }
    }

    fun didPop(routeSettings: RouteSettings) {
        routes.lastOrNull()?.let { route ->
            if (route.settings == routeSettings) {
                routes.remove(route)
                PageRoutes.lastRoute = PageRoutes.lastRoute()
            }
        }
    }

    companion object {
        private const val TAG = "PageRouteHolder"
    }
}