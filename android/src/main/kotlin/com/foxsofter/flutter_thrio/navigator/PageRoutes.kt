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
import android.app.Application
import android.os.Bundle
import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.IntCallback
import com.foxsofter.flutter_thrio.NullableIntCallback
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import com.foxsofter.flutter_thrio.extension.getPageId
import com.foxsofter.flutter_thrio.module.ModulePageObservers
import io.flutter.embedding.android.ThrioFlutterActivity
import io.flutter.embedding.android.ThrioFlutterActivityBase
import io.flutter.embedding.android.ThrioFlutterFragment
import java.lang.ref.WeakReference

internal object PageRoutes : Application.ActivityLifecycleCallbacks {

    private var prevLastRoute: PageRoute? = null

    internal var lastRoute: PageRoute? = null
        set(value) {
            if (field != value) {
                if (field != null) {
                    prevLastRoute = field
                }
                field = value
            }
        }

    var willAppearPageId = 0

    val routeHolders by lazy { mutableListOf<PageRouteHolder>() }

    val firstRouteHolder: PageRouteHolder? get() = routeHolders.firstOrNull()

    val firstFlutterRouteHolder: PageRouteHolder?
        get() = routeHolders.firstOrNull {
            ThrioFlutterActivityBase::class.java.isAssignableFrom(it.clazz)
        }

    private val removedRouteHolders by lazy { mutableListOf<PageRouteHolder>() }

    fun lastRouteHolder(pageId: Int): PageRouteHolder? {
        return routeHolders.lastOrNull { it.pageId == pageId }
    }

    fun lastRouteHolder(url: String? = null, index: Int? = null): PageRouteHolder? = when (url) {
        null -> routeHolders.lastOrNull()
        else -> routeHolders.lastOrNull { it.hasRoute(url, index) }
    }

    fun removedByRemoveRouteHolder(pageId: Int): PageRouteHolder? {
        val index = removedRouteHolders.indexOfLast { it.pageId == pageId }
        return if (index != -1) removedRouteHolders.removeAt(index) else null
    }

    fun hotRestart() {
        val firstFlutterHolder = firstFlutterRouteHolder ?: return
        if (routeHolders.size > 1) {
            val idx = routeHolders.indexOf(firstFlutterHolder)
            val holders = routeHolders.subList(idx + 1, routeHolders.size)
            for (holder in holders) {
                holder.activity?.get()?.let {
                    it.finish()
                    routeHolders.remove(holder)
                }
            }
        }
        firstFlutterHolder.routes.clear()
    }

    fun popToRouteHolders(url: String, index: Int?): List<PageRouteHolder> {
        val holder = routeHolders.lastOrNull { it.lastRoute(url, index) != null }
            ?: return listOf()

        val holderIndex = routeHolders.lastIndexOf(holder)
        return routeHolders.subList(holderIndex + 1, routeHolders.size).toMutableList()
    }

    fun hasRoute(pageId: Int): Boolean {
        return routeHolders.any { it.pageId == pageId && it.hasRoute() }
    }

    fun hasRoute(url: String? = null, index: Int? = null): Boolean = routeHolders.any {
        it.hasRoute(url, index)
    }

    fun lastRoute(url: String? = null, index: Int? = null): PageRoute? {
        if (url == null) {
            return routeHolders.lastOrNull()?.lastRoute()
        }
        for (i in routeHolders.size - 1 downTo 0) {
            val holder = routeHolders[i]
            return holder.lastRoute(url, index) ?: continue
        }
        return null
    }

    fun lastRoute(pageId: Int): PageRoute? {
        val holder = routeHolders.lastOrNull { it.pageId == pageId }
        return holder?.lastRoute()
    }

    fun allRoutes(url: String? = null): List<PageRoute> {
        val allRoutes = mutableListOf<PageRoute>()
        for (i in routeHolders.size - 1 downTo 0) {
            val holder = routeHolders[i]
            allRoutes.addAll(holder.allRoute(url))
        }
        return allRoutes.toList()
    }

    fun push(activity: Activity, route: PageRoute, result: NullableIntCallback) {
        val entrypoint = activity.intent.getEntrypoint()
        val pageId = activity.intent.getPageId()
        var holder = routeHolders.lastOrNull { it.pageId == pageId }
        if (holder == null) {
            holder = PageRouteHolder(pageId, activity.javaClass, entrypoint).apply {
                this.activity = WeakReference(activity)
            }
            routeHolders.add(holder)
        }
        holder.push(route, result)
    }

    fun <T> notify(
        url: String?,
        index: Int?,
        name: String,
        params: T?,
        result: BooleanCallback
    ) {
        if (!hasRoute(url, index)) {
            result(false)
            return
        }

        var isMatch = false
        routeHolders.forEach { holder ->
            holder.notify<T>(url, index, name, params) {
                if (it) isMatch = true
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
        val holder = routeHolders.lastOrNull()
        if (holder == null) {
            result(0)
            return
        }

        if (holder.routes.isEmpty()) { // 原生 Activity
            result(1)
        } else {
            holder.maybePop<T>(params, animated, inRoot, result)
        }
    }

    fun <T> pop(
        params: T?,
        animated: Boolean,
        inRoot: Boolean = false,
        result: BooleanCallback
    ) {
        val holder = routeHolders.lastOrNull()
        if (holder == null) {
            result(false)
            return
        }

        if (holder.routes.isEmpty()) {
            holder.activity?.get()?.finish()
            routeHolders.remove(holder)
            result(true)
        } else {
            // 记下次顶部的 Activity 的 holder
            val secondTopHolder =
                if (routeHolders.count() > 1) routeHolders[routeHolders.count() - 2] else null

            holder.pop<T>(params, animated, inRoot) { it ->
                if (it) {
                    if (!holder.hasRoute()) {
                        willAppearPageId =
                            if (secondTopHolder == null || secondTopHolder.entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) 0
                            else secondTopHolder.pageId

                        holder.activity?.get()?.let {
                            routeHolders.remove(holder)
                            it.finish()
                        }
                    }
                }
                result(it)
            }
        }
    }

    fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val routeHolder = routeHolders.lastOrNull { it.lastRoute(url, index) != null }
        if (routeHolder == null || routeHolder.activity?.get() == null) {
            result(false)
            return
        }

        routeHolder.popTo(url, index, animated) { ret ->
            if (ret) {
                val poppedToIndex = routeHolders.lastIndexOf(routeHolder)
                val removedByPopToHolders =
                    routeHolders.subList(poppedToIndex + 1, routeHolders.size).toMutableList()
                val entrypoints = mutableSetOf<String>()
                for (holder in removedByPopToHolders) {
                    if (holder.entrypoint != routeHolder.entrypoint && holder.entrypoint != NAVIGATION_NATIVE_ENTRYPOINT) {
                        entrypoints.add(holder.entrypoint)
                    }
                }

                // 清理其它引擎的页面
                entrypoints.forEach { entrypoint ->
                    removedByPopToHolders.firstOrNull { holder -> holder.entrypoint == entrypoint }
                        ?.let {
                            var poppedToSettings = RouteSettings("/", 1)
                            for (i in poppedToIndex downTo 0) {
                                val poppedToRoute = routeHolders[i].lastRoute(entrypoint)
                                if (poppedToRoute != null) {
                                    poppedToSettings = poppedToRoute.settings
                                    break
                                }
                            }
                            FlutterEngineFactory.getEngines(entrypoint).forEach { engine ->
                                engine.sendChannel.onPopTo(
                                    poppedToSettings.toArguments()
                                ) {}
                            }
                        }
                }
                while (routeHolders.lastIndex > poppedToIndex) {
                    routeHolders.removeLast()
                }
            }
            result(ret)
        }
    }

    fun remove(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val holder = routeHolders.lastOrNull { it.lastRoute(url, index) != null }
        if (holder == null) {
            result(false)
            return
        }

        holder.remove(url, index, animated) {
            if (it) {
                if (!holder.hasRoute()) {
                    if (holder == routeHolders.last() && routeHolders.count() > 1) {
                        val secondTopHolder = routeHolders[routeHolders.count() - 2]
                        if (secondTopHolder.entrypoint != NAVIGATION_NATIVE_ENTRYPOINT) {
                            willAppearPageId = secondTopHolder.pageId
                        }
                    }
                    val activity = holder.activity?.get()
                    if (activity == null) {
                        routeHolders.remove(holder)
                        removedRouteHolders.add(holder)
                    } else {
                        activity.finish()
                        routeHolders.remove(holder)
                    }
                }
            }
            result(it)
        }
    }

    fun replace(
        url: String,
        index: Int?,
        newUrl: String,
        newIndex: Int,
        result: NullableIntCallback
    ) {
        val holder = routeHolders.lastOrNull { it.lastRoute(url, index) != null }
        if (holder == null) {
            result(null)
            return
        }

        holder.replace(url, index, newUrl, newIndex, result)
    }

    fun didPop(routeSettings: RouteSettings) {
        lastRouteHolder()?.apply {
            didPop(routeSettings)
        }
    }

    fun willAppear(routeSettings: RouteSettings, routeType: RouteType) {
        if (routeType == RouteType.PUSH) {
            val holder = lastRouteHolder()
            val activity = holder?.activity?.get()
            if (holder == null
                || (activity is ThrioFlutterActivityBase && FlutterEngineFactory.isMultiEngineEnabled)
                || (activity is ThrioFlutterActivityBase && holder.routes.isEmpty())
                || activity !is ThrioFlutterActivityBase
            ) {
                return
            }
            ModulePageObservers.willAppear(routeSettings)
            lastRoute?.let {
                if (it.settings == routeSettings) {
                    if (prevLastRoute != null) {
                        ModulePageObservers.willDisappear(prevLastRoute!!.settings)
                    }
                } else {
                    ModulePageObservers.willDisappear(it.settings)
                }
            }
        } else if (routeType == RouteType.REPLACE) {
            ModulePageObservers.willAppear(routeSettings)
        } else if (routeType == RouteType.POP_TO) {
            val route = lastRoute(routeSettings.url, routeSettings.index)
            if (route != null && route != lastRoute) {
                ModulePageObservers.willAppear(routeSettings)
                lastRoute?.let {
                    ModulePageObservers.willDisappear(it.settings)
                }
            }
        }
    }

    fun didAppear(routeSettings: RouteSettings, routeType: RouteType) {
        if (routeType == RouteType.PUSH) {
            val holder = lastRouteHolder()
            val activity = holder?.activity?.get()
            if (holder == null
                || (activity is ThrioFlutterActivityBase && FlutterEngineFactory.isMultiEngineEnabled)
                || (activity is ThrioFlutterActivityBase && holder.routes.isEmpty())
                || activity !is ThrioFlutterActivityBase
            ) {
                return
            }
            ModulePageObservers.didAppear(routeSettings)
            lastRoute?.let {
                if (it.settings == routeSettings) {
                    if (prevLastRoute != null) {
                        ModulePageObservers.didDisappear(prevLastRoute!!.settings)
                    }
                } else {
                    ModulePageObservers.didDisappear(it.settings)
                }
            }
        } else if (routeType == RouteType.REPLACE) {
            ModulePageObservers.didAppear(routeSettings)
        } else if (routeType == RouteType.POP_TO) {
            val route = lastRoute(routeSettings.url, routeSettings.index)
            if (route != null && route != prevLastRoute) {
                ModulePageObservers.didAppear(routeSettings)
                prevLastRoute?.let {
                    ModulePageObservers.didDisappear(it.settings)
                }
            }
        }
    }

    fun willDisappear(routeSettings: RouteSettings, routeType: RouteType) {
        if (routeType == RouteType.POP || routeType == RouteType.REMOVE) {
            if (lastRoute == null || lastRoute?.settings == routeSettings) {
                val holder = lastRouteHolder(routeSettings.url, routeSettings.index)
                if (holder != null && holder.routes.count() < 2) {
                    return
                }
                ModulePageObservers.willDisappear(routeSettings)
                lastRouteHolder()?.let {
                    if (it.routes.count() > 1) {
                        ModulePageObservers.willAppear(it.routes[it.routes.count() - 2].settings)
                    }
                }
            }
        } else if (routeType == RouteType.REPLACE) {
            ModulePageObservers.willDisappear(routeSettings)
        } else if (routeType == RouteType.POP_TO) {
            val route = lastRoute(routeSettings.url, routeSettings.index)
            if (route != null && route != prevLastRoute) {
                ModulePageObservers.willDisappear(routeSettings)
                prevLastRoute?.let {
                    ModulePageObservers.didDisappear(it.settings)
                }
            }
        }
    }

    fun didDisappear(routeSettings: RouteSettings, routeType: RouteType) {
        if (routeType == RouteType.POP || routeType == RouteType.REMOVE) {
            if (lastRoute == null || prevLastRoute?.settings == routeSettings) {
                val holder = lastRouteHolder()
                val activity = holder?.activity?.get()
                if (holder == null
                    || (activity is ThrioFlutterActivityBase && FlutterEngineFactory.isMultiEngineEnabled)
                    || (activity is ThrioFlutterActivityBase && holder.routes.isEmpty())
                    || activity !is ThrioFlutterActivityBase
                ) {
                    return
                }
                ModulePageObservers.didDisappear(routeSettings)
                lastRoute?.let {
                    ModulePageObservers.didAppear(it.settings)
                }
            }
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        if (savedInstanceState == null) {
            var pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) {
                pageId = activity.hashCode()
                activity.intent.putExtra(NAVIGATION_ROUTE_PAGE_ID_KEY, pageId)
                var entrypoint = activity.intent.getEntrypoint()
                if (activity is ThrioFlutterActivityBase &&
                    !FlutterEngineFactory.isMultiEngineEnabled
                ) {
                    entrypoint = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
                }
                val holder = PageRouteHolder(pageId, activity.javaClass, entrypoint).also {
                    it.activity = WeakReference(activity)
                }
                routeHolders.add(holder)
            }
        } else {
            val pageId = savedInstanceState.getInt(
                NAVIGATION_ROUTE_PAGE_ID_KEY,
                NAVIGATION_ROUTE_PAGE_ID_NONE
            )
            if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE) {
                activity.intent.putExtra(NAVIGATION_ROUTE_PAGE_ID_KEY, pageId)
                val holder = routeHolders.lastOrNull { it.pageId == pageId }
                holder?.activity = WeakReference(activity)
            }
        }
    }

    override fun onActivityStarted(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE) {
            val holder = routeHolders.lastOrNull { it.pageId == pageId }
            holder?.activity = WeakReference(activity)
        }
    }

    override fun onActivityPreResumed(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE && NavigationController.routeType != RouteType.POP_TO) {
            routeHolders.lastOrNull { it.pageId == pageId }?.let { holder ->
                holder.lastRoute()?.settings?.let {
                    ModulePageObservers.willAppear(it)
                }
            }
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE) {
            outState.putInt(NAVIGATION_ROUTE_PAGE_ID_KEY, pageId)
        }
    }

    override fun onActivityResumed(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE && NavigationController.routeType != RouteType.POP_TO) {
            val holder = routeHolders.lastOrNull { it.pageId == pageId }
            holder?.activity = WeakReference(activity)
            lastRoute = holder?.lastRoute()
            if (lastRoute != null) {
                ModulePageObservers.didAppear(lastRoute!!.settings)
            }
        }
    }

    override fun onActivityPrePaused(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE && NavigationController.routeType != RouteType.POP_TO) {
            routeHolders.lastOrNull { it.pageId == pageId }?.let { holder ->
                holder.lastRoute()?.settings?.let {
                    ModulePageObservers.willDisappear(it)
                }
            }
        }
    }

    override fun onActivityPaused(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE && NavigationController.routeType != RouteType.POP_TO) {
            routeHolders.lastOrNull { it.pageId == pageId }?.let { holder ->
                holder.lastRoute()?.settings?.let {
                    ModulePageObservers.didDisappear(it)
                }
            }
        }
    }

    override fun onActivityStopped(activity: Activity) {
    }

    override fun onActivityDestroyed(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE) {
            routeHolders.lastOrNull { it.pageId == pageId }?.apply {
                if (activity.isFinishing) {
                    routeHolders.remove(this)
                    this.activity = null
                    // 需重置标记位，如果 ThrioFlutterActivity 曾经是首页的话，下次进入的时候才会打开第一个页面
                    if (routeHolders.isEmpty()) {
                        ThrioFlutterFragment.isInitialUrlPushed = false
                        ThrioFlutterActivity.isInitialUrlPushed = false
                    }
                }
            }
        }
    }
}