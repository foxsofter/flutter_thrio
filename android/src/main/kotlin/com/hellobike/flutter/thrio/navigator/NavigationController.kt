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
import android.content.Context
import android.content.Intent
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableAnyCallback
import com.hellobike.flutter.thrio.NullableIntCallback
import io.flutter.embedding.android.ThrioActivity
import java.util.*
import kotlin.concurrent.timerTask

internal object NavigationController {

    var context: Context? = null

    var routeAction = RouteAction.NONE

    object Push {

        private var result: NullableIntCallback? = null
        private var poppedResult: NullableAnyCallback? = null

        fun push(url: String,
                 params: Any? = null,
                 animated: Boolean,
                 fromEntrypoint: String = "",
                 poppedResult: NullableAnyCallback? = null,
                 result: NullableIntCallback?) {
            if (routeAction != RouteAction.NONE) {
                result?.invoke(null)
                return
            }

            val lastRoute = PageRoutes.lastRoute(url)
            val index = (lastRoute?.settings?.index?.plus(1)) ?: 1

            val settings = RouteSettings(url, index).also {
                it.params = params
                it.animated = animated
            }

            val builder = IntentBuilders.intentBuilders[url] ?: IntentBuilders.flutterIntentBuilder

            var entrypoint = NAVIGATION_NATIVE_ENTRYPOINT

            val lastActivityHolder = PageRoutes.lastActivityHolder()
            val lastActivity = lastActivityHolder?.activity?.get()
            val lastEntrypoint = lastActivityHolder?.entrypoint

            if (builder is FlutterIntentBuilder) {
                entrypoint = if (FlutterEngineFactory.isMultiEngineEnabled) {
                    url.getEntrypoint()
                } else {
                    NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
                }
            }

            val settingsData = hashMapOf<String, Any?>().also {
                it.putAll(settings.toArguments())
            }

            val intent = if (lastActivity != null
                    && lastActivity is ThrioActivity
                    && lastEntrypoint == entrypoint) {
                lastActivity?.intent
            } else {
                builder.build(context!!, entrypoint).apply {
                    if (!animated) {
                        addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                    }
                }
            }?.apply {
                putExtra(NAVIGATION_ROUTE_SETTINGS_KEY, settingsData)
                putExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY, entrypoint)
                putExtra(NAVIGATION_ROUTE_FROM_ENTRYPOINT_KEY, fromEntrypoint)
            }

            routeAction = RouteAction.PUSH

            this.result = result
            this.poppedResult = poppedResult

            if (builder is FlutterIntentBuilder) {
                if (lastActivity != null
                        && lastActivity is ThrioActivity
                        && lastEntrypoint == entrypoint) {
                    lastActivity?.let {
                        doPush(it)
                    }
                } else {
                    FlutterEngineFactory.startup(context!!, entrypoint, object : EngineReadyListener {
                        override fun onReady(params: Any?) {
                            if (params !is String || params != entrypoint) {
                                throw IllegalStateException("entrypoint must match.")
                            }
                            context!!.startActivity(intent)
                        }
                    })
                }
            } else {
                context!!.startActivity(intent)
            }
        }

        fun doPush(activity: Activity) {
            if (routeAction != RouteAction.PUSH) {
                result = null
                poppedResult = null
                return
            }
            routeAction = RouteAction.PUSHING

            checkNotNull(result) { "result must not be null" }
            val settings = activity.intent.getRouteSettings() ?: return
            val entrypoint = activity.intent.getEntrypoint()
            val fromEntryPoint = activity.intent.getFromEntrypoint()

            var pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_PAGE_ID_NONE) {
                pageId = activity.hashCode()
                activity.intent.putExtra(NAVIGATION_PAGE_ID_KEY, pageId)
            }
            settings.isNested = PageRoutes.hasRoute(pageId)

            val route = PageRoute(settings, activity::class.java)
            route.fromEntrypoint = fromEntryPoint
            route.entrypoint = entrypoint
            route.poppedResult = poppedResult
            poppedResult = null

            val previousRouteSettings = PageRoutes.lastRoute()?.settings

            if (entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) { // 原生页面
                PageObservers.onCreate(settings)
            }

            PageRoutes.push(activity, route) { index ->
                if (index == null) {
                    if (!PageRoutes.hasRoute(pageId)) {
                        activity.finish()
                    }
                    result?.invoke(null)
                } else {
                    result?.invoke(index)
                }
                routeAction = RouteAction.NONE
                result = null

                if (index != null && entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) {
                    RouteObservers.didPush(settings, previousRouteSettings)
                }
            }
        }
    }

    object Notify {

        fun notify(url: String,
                   index: Int? = null,
                   name: String,
                   params: Any? = null,
                   result: BooleanCallback? = null) {
            if ((index != null && index < 0) || !PageRoutes.hasRoute(url)) {
                result?.invoke(false)
                return
            }

            PageRoutes.notify(url, index, name, params) {
                result?.invoke(it)
            }

            PageRoutes.lastActivityHolder()?.activity?.get()?.let { activity ->
                doNotify(activity)
            }
        }

        fun doNotify(activity: Activity) {
            val pageId = activity.intent.getPageId()
            val route = PageRoutes.lastRoute(pageId) ?: return

            val notifications = route.removeNotify()
            notifications.forEach {
                if (activity is ThrioActivity) {
                    val arguments = if (it.value == null) mapOf<String, Any>(
                            "__event_name__" to "__onNotify__",
                            "url" to route.settings.url,
                            "index" to route.settings.index,
                            "name" to it.key
                    ) else mapOf<String, Any>(
                            "__event_name__" to "__onNotify__",
                            "url" to route.settings.url,
                            "index" to route.settings.index,
                            "name" to it.key,
                            "params" to it.value!!
                    )
                    Log.i("Thrio", "page ${route.settings.url} index ${route.settings.index} notify")
                    activity.onNotify(arguments) {}
                } else if (activity is PageNotifyListener) {
                    activity.onNotify(it.key, it.value)
                }
            }
        }
    }

    object Pop {
        fun pop(params: Any? = null,
                animated: Boolean = true,
                result: BooleanCallback? = null) {
            if (routeAction != RouteAction.NONE) {
                result?.invoke(false)
                return
            }

            routeAction = RouteAction.POPPING

            val route = PageRoutes.lastRoute()
            if (route?.settings == null) {
                result?.invoke(false)
                routeAction = RouteAction.NONE
            }

            PageRoutes.pop(params, animated) {
                result?.invoke(it)
                routeAction = RouteAction.NONE
                if (it && route?.entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) {
                    val previousRouteSettings = PageRoutes.lastRoute()?.settings
                    RouteObservers.didPop(route.settings, previousRouteSettings)
                }
            }
        }
    }

    object PopTo {
        private var result: BooleanCallback? = null
        private var poppedToRoute: PageRoute? = null
        private val destroyingActivityHolders by lazy { mutableListOf<PageActivityHolder>() }
        private val activityHolders by lazy { mutableListOf<PageActivityHolder>() }

        fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback? = null) {
            if (routeAction != RouteAction.NONE) {
                result?.invoke(false)
                return
            }

            if (index != null && index < 0) {
                result?.invoke(false)
                routeAction = RouteAction.NONE
                return
            }

            val poppedToRoute = PageRoutes.lastRoute(url, index)
            if (poppedToRoute == null || poppedToRoute == PageRoutes.lastRoute()) {
                result?.invoke(false)
                routeAction = RouteAction.NONE
                return
            }
            routeAction = RouteAction.POP_TO
            poppedToRoute.settings.animated = animated

            PageRoutes.lastActivityHolder(url, index)?.let {
                activityHolders.add(it)
            }
            val willBeRemovedHolders = PageRoutes.removeByPopToActivityHolder(url, index)
            activityHolders.addAll(willBeRemovedHolders.takeWhile { it.clazz != poppedToRoute.clazz })

            val lastRoute = PageRoutes.lastRoute()
            PageRoutes.popTo(url, index, animated) { ret ->
                if (ret) {
                    if (ret && poppedToRoute.entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) {
                        RouteObservers.didPopTo(poppedToRoute.settings, lastRoute?.settings)
                    }
                    if (willBeRemovedHolders.isEmpty()) {
                        result?.invoke(true)
                        routeAction = RouteAction.NONE
                        return@popTo
                    }
                    // 顶上存在其它的 Activity，需要 clearTop
                    if (activityHolders.count() == 1) {
                        result?.invoke(true)
                        routeAction = RouteAction.NONE
                    } else {
                        this.result = result
                        this.poppedToRoute = poppedToRoute
                    }
                    startActivity(activityHolders.last(), poppedToRoute)
                } else {
                    result?.invoke(false)
                    destroyingActivityHolders.clear()
                    routeAction = RouteAction.NONE
                }
            }
        }

        private fun startActivity(activityHolder: PageActivityHolder, route: PageRoute) {
            val builder = object : IntentBuilder {
                override fun getActivityClz(): Class<out Activity> {
                    return activityHolder.clazz
                }
            }
            builder.build(context!!, activityHolder.entrypoint).let { intent ->
                if (!route.settings.animated) {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                } else {
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                }

                intent.putExtra(NAVIGATION_PAGE_ID_KEY, activityHolder.pageId)
                activityHolder.lastRoute()?.apply {
                    val settingsData = hashMapOf<String, Any?>().also {
                        it.putAll(settings.toArguments())
                    }
                    intent.putExtra(NAVIGATION_ROUTE_SETTINGS_KEY, settingsData)
                    intent.putExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY, entrypoint)
                    intent.putExtra(NAVIGATION_ROUTE_FROM_ENTRYPOINT_KEY, fromEntrypoint)
                }

                context?.startActivity(intent)
            }
        }

        fun doPopTo(activity: Activity) {
            if (routeAction != RouteAction.POP_TO) {
                return
            }

            // 清掉popTo还未关闭的Activity
            val pageId = activity.intent.getPageId()
            val index = activityHolders.indexOfLast { it.pageId == pageId }
            if (pageId != NAVIGATION_PAGE_ID_NONE && index != -1) {
                val removingActivityHolder = activityHolders.removeAt(index)
                if (!destroyingActivityHolders.contains(removingActivityHolder)) {
                    destroyingActivityHolders.add(removingActivityHolder)
                    startActivity(removingActivityHolder, poppedToRoute!!)
                    if (activityHolders.isEmpty()) {
                        return
                    }
                }
            }

            if (activityHolders.isEmpty()) {
                destroyingActivityHolders.clear()
                routeAction = RouteAction.NONE
                result?.invoke(true)
                result = null
            } else {
                val activityHolder = activityHolders.lastOrNull { !destroyingActivityHolders.contains(it) }
                if (activityHolder != null) {
                    startActivity(activityHolder, poppedToRoute!!)
                }
            }
        }

        fun didDestroy() {
            if (destroyingActivityHolders.isEmpty() && routeAction == RouteAction.NONE) {
                poppedToRoute?.let { route ->
                    PageRoutes.lastActivityHolder(route.settings.url, route.settings.index)?.let { activityHolder ->
                        activityHolder.activity?.get()?.let { activity ->
                            if (activity is ThrioActivity) {
                                Timer().schedule(timerTask {
                                    // 在多个 Activity 互相嵌套的场景下，需要确保呈现的 Activity 的
                                    // onResume 方法最后被调用，在这里加了一个延迟时间
                                    // 这不是最好的解决方案，但这是目前多引擎的场景下能解决问题的一个方案
                                    // 可能会出现Dart页面闪过进度条的问题
                                    activity.runOnUiThread {
                                        activity.onResume()
                                    }
                                }, 400)
                            }
                        }
                    }
                }
                poppedToRoute = null
            }
        }
    }

    object Remove {

        fun remove(url: String,
                   index: Int?,
                   animated: Boolean = true,
                   result: BooleanCallback? = null) {
            if (routeAction != RouteAction.NONE) {
                result?.invoke(false)
                return
            }

            routeAction = RouteAction.REMOVING

            PageRoutes.remove(url, index, animated) {
                result?.invoke(it)
                routeAction = RouteAction.NONE
            }
        }

        fun doRemove(activity: Activity) {
            val pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_PAGE_ID_NONE) {
                return
            }
            val activityHolder = PageRoutes.lastRemovedActivityHolder(pageId)
            if (activityHolder != null) {
                activity.finish()
            }
        }
    }
}
