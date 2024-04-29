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
import android.content.Intent
import android.os.Bundle
import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.NullableAnyCallback
import com.foxsofter.flutter_thrio.NullableIntCallback
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import com.foxsofter.flutter_thrio.extension.getFromEntrypoint
import com.foxsofter.flutter_thrio.extension.getFromPageId
import com.foxsofter.flutter_thrio.extension.getPageId
import com.foxsofter.flutter_thrio.extension.getRouteSettings
import com.foxsofter.flutter_thrio.module.ModuleIntentBuilders
import com.foxsofter.flutter_thrio.module.ModuleJsonSerializers
import com.foxsofter.flutter_thrio.module.ModuleRouteObservers
import io.flutter.embedding.android.ThrioFlutterActivityBase
import java.lang.ref.WeakReference


internal object NavigationController : Application.ActivityLifecycleCallbacks {

    fun isInitialRoute(url: String, index: Int?): Boolean {
        if (PageRoutes.firstRouteHolder?.allRoute()?.isNotEmpty() == true) {
            val settings = PageRoutes.firstRouteHolder?.firstRoute()?.settings
            return settings?.url == url && settings.index == index
        }
        return false
    }

    fun hotRestart() {
        val firstFlutterHolder = PageRoutes.firstFlutterRouteHolder ?: return
        val route = firstFlutterHolder.firstRoute() ?: return
        PageRoutes.hotRestart()
        Push.push(
            route.settings.url,
            route.settings.params,
            route.settings.animated,
            route.fromEntrypoint,
            null,
            null,
            null,
            route.fromPageId,
        ) { }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        context = WeakReference(activity)

        Remove.doRemove(activity)
    }

    override fun onActivityStarted(activity: Activity) {
        PopTo.doPopTo(activity)
        Remove.doRemove(activity)
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
    }

    override fun onActivityResumed(activity: Activity) {
        context = WeakReference(activity)

        Notify.doNotify(activity)
        val pageId = activity.intent.getPageId()
        if (activity !is ThrioFlutterActivityBase || PageRoutes.lastRoute(pageId) != null) {
            Push.doPush(activity)
        }
    }

    override fun onActivityPaused(activity: Activity) {
    }

    override fun onActivityStopped(activity: Activity) {
    }

    override fun onActivityDestroyed(activity: Activity) {
        if (activity.isFinishing) {
            PopTo.didPopTo(activity)
        }
    }

    private var context: WeakReference<out Activity>? = null

    var routeType = RouteType.NONE

    object Push {

        private var result: NullableIntCallback? = null
        private var poppedResult: NullableAnyCallback? = null

        fun <T> push(
            url: String,
            params: T? = null,
            animated: Boolean,
            fromEntrypoint: String = NAVIGATION_NATIVE_ENTRYPOINT,
            fromURL: String? = null,
            prevURL: String? = null,
            innerURL: String? = null,
            fromPageId: Int = NAVIGATION_ROUTE_PAGE_ID_NONE,
            poppedResult: NullableAnyCallback? = null,
            result: NullableIntCallback?,
        ) {
            if (routeType != RouteType.NONE) {
                result?.invoke(null)
                return
            }

            routeType = RouteType.PUSH

            // 获取 lastActivity & lastEntrypoint & lastPageId
            val lastHolder = PageRoutes.lastRouteHolder()
            val lastActivity = lastHolder?.activity?.get() ?: context?.get()
            if (lastActivity == null) {
                routeType = RouteType.NONE
                result?.invoke(null)
                return
            }
            val lastEntrypoint = lastHolder?.entrypoint

            // 获取 builder & entrypoint
            val builder = ModuleIntentBuilders.intentBuilders[url]
                ?: ModuleIntentBuilders.flutterIntentBuilder
            var entrypoint = NAVIGATION_NATIVE_ENTRYPOINT
            if (builder is FlutterIntentBuilder) {
                entrypoint = if (FlutterEngineFactory.isMultiEngineEnabled) {
                    url.getEntrypoint()
                } else {
                    NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
                }
            }

            // 确定索引
            val lastRoute = PageRoutes.lastRoute(url)
            val index = (lastRoute?.settings?.index?.plus(1)) ?: 1
            // 序列化参数
            val settings = RouteSettings(url, index).also {
                it.params = ModuleJsonSerializers.serializeParams(params)
                it.fromURL = fromURL
                it.prevURL = prevURL ?: ThrioNavigator.lastRoute()?.settings?.url
                it.innerURL = innerURL
                it.animated = animated
            }
            val settingsData = hashMapOf<String, Any?>().also {
                it.putAll(settings.toArguments())
            }
            // 准备 intent
            val intent = if (lastActivity is ThrioFlutterActivityBase &&
                (lastEntrypoint == entrypoint || PageRoutes.lastRoute == null)
            ) {
                lastActivity.intent // 复用 ThrioFlutterFragmentActivity
            } else {
                builder.build(lastActivity, entrypoint).apply {
                    if (!animated) {
                        addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                    }
                }
            }?.apply {
                putExtra(NAVIGATION_ROUTE_SETTINGS_KEY, settingsData)
                putExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY, entrypoint)
                putExtra(NAVIGATION_ROUTE_FROM_ENTRYPOINT_KEY, fromEntrypoint)
                putExtra(NAVIGATION_ROUTE_FROM_PAGE_ID_KEY, fromPageId)
            }

            this.result = result
            this.poppedResult = poppedResult

            if (builder is FlutterIntentBuilder) {
                if (lastActivity is ThrioFlutterActivityBase && PageRoutes.lastRoute == null) {
                    doPush(
                        lastActivity,
                        routeSettings = settings
                    ) // ThrioFlutterFragmentActivity 做为首页被打开
                } else if (lastActivity is ThrioFlutterActivityBase && lastEntrypoint == entrypoint) {
                    doPush(lastActivity) // ThrioFlutterFragmentActivity 作为最后打开的 Activity，且是同样的 entrypoint
                } else {
                    lastActivity.startActivity(intent)
                }
            } else {
                // 原生的 Activity
                lastActivity.startActivity(intent)
            }
        }

        internal fun doPush(activity: Activity, routeSettings: RouteSettings? = null) {
            if (routeType != RouteType.PUSH) {
                return
            }

            val settings = routeSettings ?: activity.intent.getRouteSettings()
            if (settings == null) {
                result?.invoke(null)
                result = null
                return
            }

            // 开始 push Flutter 页面
            routeType = RouteType.PUSHING

            // 设置 pageId
            var pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) {
                pageId = activity.hashCode()
                activity.intent.putExtra(NAVIGATION_ROUTE_PAGE_ID_KEY, pageId)
            }

            val entrypoint = activity.intent.getEntrypoint()
            val fromEntryPoint = activity.intent.getFromEntrypoint()
            val fromPageId = activity.intent.getFromPageId()

            // 这个 activity 下已存在 PageRoute 表示为嵌套的页面
            settings.isNested = PageRoutes.hasRoute(pageId)

            // 生成新的 PageRoute
            val route = PageRoute(settings, activity::class.java)
            route.fromEntrypoint = fromEntryPoint
            route.entrypoint = entrypoint
            route.fromPageId = fromPageId
            route.poppedResult = poppedResult
            poppedResult = null

            PageRoutes.push(activity, route) { index ->
                if (index == null) {
                    if (!PageRoutes.hasRoute(pageId)) {
                        activity.finish()
                    }
                }
                routeType = RouteType.NONE
                result?.invoke(index)
                result = null
            }
        }
    }

    object Notify {

        fun <T> notify(
            url: String? = null,
            index: Int? = null,
            name: String,
            params: T? = null,
            result: BooleanCallback? = null
        ) {
            if ((url != null && index != null && index < 0) || !PageRoutes.hasRoute(url)) {
                result?.invoke(false)
                return
            }

            PageRoutes.notify<T>(url, index, name, params) {
                result?.invoke(it)
            }

            PageRoutes.lastRouteHolder()?.activity?.get()?.let { activity ->
                doNotify(activity)
            }
        }

        internal fun doNotify(activity: Activity) {
            val pageId = activity.intent.getPageId()
            val route = PageRoutes.lastRoute(pageId) ?: return

            val notifications = route.removeNotify()
            notifications.forEach {
                if (activity is ThrioFlutterActivityBase) {
                    val arguments = if (it.value == null) mapOf<String, Any>(
                        "__event_name__" to "__onNotify__",
                        "url" to route.settings.url,
                        "index" to route.settings.index,
                        "name" to it.key
                    ) else mapOf(
                        "__event_name__" to "__onNotify__",
                        "url" to route.settings.url,
                        "index" to route.settings.index,
                        "name" to it.key,
                        "params" to ModuleJsonSerializers.serializeParams(it.value)
                    )
                    Log.i(
                        "Thrio",
                        "url-> ${route.settings.url} index-> ${route.settings.index} notify"
                    )
                    activity.onNotify(arguments) {}
                } else if (activity is PageNotifyListener) {
                    activity.onNotify(it.key, it.value)
                }
            }
        }
    }

    object Pop {
        fun <T> maybePop(
            params: T? = null,
            animated: Boolean = true,
            result: BooleanCallback? = null
        ) {
            var lastHolder = PageRoutes.lastRouteHolder()
            if (lastHolder == null) {
                result?.invoke(false)
                return
            }
            var activity = lastHolder.activity?.get() ?: return // 不应该会走到这
            // 如果该 activity 正在被关闭，则对其下的 activity 进行 pop
            while (activity.isFinishing) {
                val idx = PageRoutes.routeHolders.indexOf(lastHolder)
                if (idx < 1) {
                    result?.invoke(false)
                    return
                }
                lastHolder = PageRoutes.routeHolders[idx - 1]
                activity = lastHolder.activity?.get() ?: return // 不应该会走到这
            }
            if (lastHolder == null) {
                result?.invoke(false)
                return
            }
            val inRoot = lastHolder == PageRoutes.firstRouteHolder
            if (inRoot && lastHolder.allRoute().count() < 2) {
                if (activity is ThrioFlutterActivityBase) {
                    PageRoutes.maybePop<T>(params, animated, true) {
                        if (it == 1) {
                            if (activity.shouldMoveToBack()) {
                                activity.moveTaskToBack(false)
                            }
                        }
                        result?.invoke(it != 0)
                    }
                } else {
                    activity.onBackPressed()
                    result?.invoke(false)
                }
                return
            }
            PageRoutes.maybePop<T>(params, animated, inRoot) {
                if (it == 1) {
                    pop<T>(params, animated, result)
                } else {
                    result?.invoke(it != 0)
                }
            }
        }

        fun <T> pop(
            params: T? = null,
            animated: Boolean = true,
            result: BooleanCallback? = null
        ) {
            if (routeType != RouteType.NONE) {
                result?.invoke(false)
                return
            }
            var lastHolder = PageRoutes.lastRouteHolder()
            if (lastHolder == null) {
                result?.invoke(false)
                return
            }
            routeType = RouteType.POP

            var activity = lastHolder.activity?.get() ?: return // 不应该会走到这
            // 如果该 activity 正在被关闭，则对其下的 activity 进行 pop
            while (activity.isFinishing) {
                val idx = PageRoutes.routeHolders.indexOf(lastHolder)
                if (idx < 1) {
                    routeType = RouteType.NONE
                    result?.invoke(false)
                    return
                }
                lastHolder = PageRoutes.routeHolders[idx - 1]
                activity = lastHolder.activity?.get() ?: return // 不应该会走到这
            }
            if (lastHolder == null) {
                routeType = RouteType.NONE
                result?.invoke(false)
                return
            }
            val inRoot = lastHolder == PageRoutes.firstRouteHolder

            if (inRoot && lastHolder.allRoute().count() < 2) {
                if (activity is ThrioFlutterActivityBase) {
                    activity.moveTaskToBack(false)
                } else {
                    activity.onBackPressed()
                }
                routeType = RouteType.NONE
                result?.invoke(true)
            } else {
                PageRoutes.pop<T>(lastHolder, params, animated) {
                    routeType = RouteType.NONE
                    result?.invoke(it)
                }
            }
        }

        fun <T> popFlutter(
            params: T? = null,
            animated: Boolean = true,
            result: BooleanCallback? = null
        ) {
            if (routeType != RouteType.NONE) {
                result?.invoke(false)
                return
            }
            val lastHolder = PageRoutes.lastFlutterRouteHolder()
            if (lastHolder == null) {
                result?.invoke(false)
                return
            }
            routeType = RouteType.POP

            val inRoot = lastHolder == PageRoutes.firstRouteHolder

            if (inRoot && lastHolder.allRoute().count() < 2) {
                val activity = lastHolder.activity?.get() ?: return // 不应该会走到这
                if (activity is ThrioFlutterActivityBase) {
                    activity.moveTaskToBack(false)
                } else {
                    activity.onBackPressed()
                }
                routeType = RouteType.NONE
                result?.invoke(true)
            } else {
                PageRoutes.pop<T>(lastHolder, params, animated) {
                    routeType = RouteType.NONE
                    result?.invoke(it)
                }
            }
        }

        fun canPop(result: BooleanCallback? = null) {
            val lastHolder = PageRoutes.lastRouteHolder()
            if (lastHolder == null) {
                result?.invoke(false)
                return
            }
            val inRoot = lastHolder == PageRoutes.firstRouteHolder
            lastHolder.canPop(inRoot, result)
        }
    }

    object PopTo {
        private var result: BooleanCallback? = null
        private var poppedToRoute: PageRoute? = null
        private var poppedToHolder: PageRouteHolder? = null
        private val poppedToHolders by lazy { mutableListOf<PageRouteHolder>() }
        private var poppedToHolderCount = 0
        private val poppingToHolders by lazy { mutableListOf<PageRouteHolder>() }
        private val destroyingHolders by lazy { mutableListOf<PageRouteHolder>() }

        fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback? = null) {
            if (routeType != RouteType.NONE || (index != null && index < 0)) {
                result?.invoke(false)
                return
            }

            val poppedToRoute = PageRoutes.lastRoute(url, index)
            if (poppedToRoute == null || poppedToRoute == PageRoutes.lastRoute()) {
                result?.invoke(false)
                return
            }
            routeType = RouteType.POPPING_TO

            poppedToRoute.settings.animated = animated
            val poppedToHolder = PageRoutes.lastRouteHolder(url, index)
            val poppedToHolders = PageRoutes.popToRouteHolders(url, index)

            PageRoutes.popTo(url, index, animated) { ret ->
                if (ret) {
                    if (poppedToRoute.entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) {
                        ModuleRouteObservers.didPopTo(poppedToRoute.settings)
                    }
                    // 顶上不存在其它的 Activity
                    if (poppedToHolders.isEmpty()) {
                        routeType = RouteType.NONE
                        result?.invoke(true)
                    } else { // 顶上存在其它的 Activity
                        this.result = result
                        this.poppedToRoute = poppedToRoute
                        this.poppedToHolder = poppedToHolder
                        this.poppedToHolders.addAll(poppedToHolders)
                        poppedToHolderCount = poppedToHolders.count()
                        val holder = this.poppedToHolders.last()
                        poppingToHolders.add(holder)
                        this.poppedToHolders.remove(holder)
                        Log.i("NavigationController", "finish->${holder.pageId}")
                        holder.activity?.get()?.finish()
                    }
                } else {
                    routeType = RouteType.NONE
                    result?.invoke(false)
                }
            }
        }

        internal fun doPopTo(activity: Activity) {
            if (routeType != RouteType.POPPING_TO) {
                return
            }
            val pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) {
                routeType = RouteType.NONE
                result?.invoke(false)
                result = null
                return
            }
            val index = poppedToHolders.indexOfLast { it.pageId == pageId }
            if (index == -1) {
                routeType = RouteType.NONE
                result?.invoke(false)
                result = null
                return
            }
            if (poppedToHolder != null && poppedToHolder!!.pageId == pageId) {
                poppedToHolder?.activity?.get()?.let {
                    poppedToHolder = null
                }
                routeType = RouteType.NONE
                result?.invoke(false)
                result = null
                return
            }
            val holder = poppedToHolders[index]
            if (!poppingToHolders.contains(holder)) {
                poppedToHolders.removeAt(index)
                poppingToHolders.add(holder)
                activity.finish()
            }
        }

        internal fun didPopTo(activity: Activity) {
            if (routeType != RouteType.POPPING_TO) {
                return
            }
            val pageId = activity.intent.getPageId()
            val index = poppingToHolders.indexOfLast { it.pageId == pageId }
            if (pageId != NAVIGATION_ROUTE_PAGE_ID_NONE && index != -1) {
                destroyingHolders.add(poppingToHolders[index])
                if (poppingToHolders.count() == poppedToHolderCount &&
                    destroyingHolders.count() == poppedToHolderCount
                ) {
                    routeType = RouteType.NONE
                    result?.invoke(true)
                    result = null
                    poppedToRoute = null
                    poppedToHolderCount = 0
                    poppingToHolders.clear()
                    destroyingHolders.clear()
                }
            }
        }
    }

    object Remove {

        fun remove(
            url: String,
            index: Int?,
            animated: Boolean = true,
            result: BooleanCallback? = null
        ) {
            if (routeType != RouteType.NONE) {
                result?.invoke(false)
                return
            }

            routeType = RouteType.REMOVING

            PageRoutes.remove(url, index, animated) {
                routeType = RouteType.NONE
                result?.invoke(it)
            }
        }

        internal fun doRemove(activity: Activity) {
            val pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) {
                return
            }

            PageRoutes.removedByRemoveRouteHolder(pageId)?.activity?.get()?.apply {
                this.finish()
            }
        }
    }

    object Replace {

        fun replace(
            url: String,
            index: Int?,
            newUrl: String,
            result: NullableIntCallback? = null
        ) {
            if (routeType != RouteType.NONE) {
                result?.invoke(null)
                return
            }
            routeType = RouteType.REPLACE

            val lastNewRoute = PageRoutes.lastRoute(newUrl)
            val newIndex = (lastNewRoute?.settings?.index?.plus(1)) ?: 1
            // 目前只实现 Flutter 页面之间的 replace，可以不考虑 Activity 被杀掉的情况
            PageRoutes.replace(url, index, newUrl, newIndex) {
                routeType = RouteType.NONE
                result?.invoke(it)
            }
        }
    }
}
 