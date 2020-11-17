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
import android.app.Application
import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableAnyCallback
import com.hellobike.flutter.thrio.NullableIntCallback
import io.flutter.embedding.android.ThrioActivity

internal object NavigationController : Application.ActivityLifecycleCallbacks {

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        context = context ?: activity

        Remove.doRemove(activity)
        Push.doPush(activity)
    }

    override fun onActivityStarted(activity: Activity) {
        PopTo.doPopTo(activity)
        Remove.doRemove(activity)
        Push.doPush(activity)
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
    }

    override fun onActivityResumed(activity: Activity) {
        Notify.doNotify(activity)
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

    private var context: Context? = null

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

            routeAction = RouteAction.PUSH

            val lastRoute = PageRoutes.lastRoute(url)
            val index = (lastRoute?.settings?.index?.plus(1)) ?: 1

            val settings = RouteSettings(url, index).also {
                it.params = params
                it.animated = animated
            }

            val builder = IntentBuilders.intentBuilders[url] ?: IntentBuilders.flutterIntentBuilder

            var entrypoint = NAVIGATION_NATIVE_ENTRYPOINT

            val lastHolder = PageRoutes.lastRouteHolder()
            val lastActivity = lastHolder?.activity?.get()
            val lastEntrypoint = lastHolder?.entrypoint

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
                lastActivity.intent
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


            this.result = result
            this.poppedResult = poppedResult

            if (builder is FlutterIntentBuilder) {
                if (lastActivity != null
                        && lastActivity is ThrioActivity
                        && lastEntrypoint == entrypoint) {
                    doPush(lastActivity)
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

        internal fun doPush(activity: Activity) {
            if (routeAction != RouteAction.PUSH) {
                return
            }
            routeAction = RouteAction.PUSHING

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

            PageRoutes.push(activity, route) { index ->
                if (index == null) {
                    if (!PageRoutes.hasRoute(pageId)) {
                        activity.finish()
                    }
                }
                result?.invoke(index)
                result = null
                routeAction = RouteAction.NONE

                if (index != null && entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) {  // 只触发原生页面
                    RouteObservers.didPush(settings)
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

            PageRoutes.lastRouteHolder()?.activity?.get()?.let { activity ->
                doNotify(activity)
            }
        }

        internal fun doNotify(activity: Activity) {
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
                    ) else mapOf(
                            "__event_name__" to "__onNotify__",
                            "url" to route.settings.url,
                            "index" to route.settings.index,
                            "name" to it.key,
                            "params" to it.value!!
                    )
                    Log.v("Thrio", "page ${route.settings.url} '" +
                            "'index ${route.settings.index} notify")
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

            PageRoutes.pop(params, animated) {
                result?.invoke(it)
                routeAction = RouteAction.NONE
            }
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
            if (routeAction != RouteAction.NONE || (index != null && index < 0)) {
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
            routeAction = RouteAction.POPPING_TO

            poppedToRoute.settings.animated = animated
            val poppedToHolder = PageRoutes.lastRouteHolder(url, index)
            val poppedToHolders = PageRoutes.popToRouteHolders(url, index)

            val lastRoute = PageRoutes.lastRoute()
            PageRoutes.popTo(url, index, animated) { ret ->
                if (ret) {
                    if (ret && poppedToRoute.entrypoint == NAVIGATION_NATIVE_ENTRYPOINT) {
                        RouteObservers.didPopTo(poppedToRoute.settings)
                    }
                    // 顶上不存在其它的 Activity
                    if (poppedToHolders.isEmpty()) {
                        result?.invoke(true)
                        routeAction = RouteAction.NONE
                    } else { // 顶上存在其它的 Activity
                        this.result = result
                        this.poppedToRoute = poppedToRoute
                        this.poppedToHolder = poppedToHolder
                        this.poppedToHolders.addAll(poppedToHolders)
                        poppedToHolderCount = poppedToHolders.count()
                        val holder = this.poppedToHolders.last()
                        poppingToHolders.add(holder)
                        this.poppedToHolders.remove(holder)
                        Log.v("NavigationController", "finish->${holder.pageId}")
                        holder.activity?.get()?.finish()
                    }
                } else {
                    result?.invoke(false)
                    routeAction = RouteAction.NONE
                }
            }
        }

        internal fun doPopTo(activity: Activity) {
            if (routeAction != RouteAction.POPPING_TO) {
                return
            }
            val pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_PAGE_ID_NONE) {
                return
            }
            val index = poppedToHolders.indexOfLast { it.pageId == pageId }
            if (index == -1 && poppedToHolder != null && poppedToHolder!!.pageId == pageId) {
                poppedToHolder?.activity?.get()?.let {
                    poppedToHolder = null
                    if (it is ThrioActivity) {
                        it.onResume()
                    }
                }
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
            if (routeAction != RouteAction.POPPING_TO) {
                return
            }
            val pageId = activity.intent.getPageId()
            val index = poppingToHolders.indexOfLast { it.pageId == pageId }
            if (pageId != NAVIGATION_PAGE_ID_NONE && index != -1) {
                destroyingHolders.add(poppingToHolders[index])
                if (poppingToHolders.count() == poppedToHolderCount &&
                        destroyingHolders.count() == poppedToHolderCount) {
                    result?.invoke(true)
                    result = null
                    routeAction = RouteAction.NONE
                    poppedToRoute = null
                    poppedToHolderCount = 0
                    poppingToHolders.clear()
                    destroyingHolders.clear()
                }
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

        internal fun doRemove(activity: Activity) {
            val pageId = activity.intent.getPageId()
            if (pageId == NAVIGATION_PAGE_ID_NONE) {
                return
            }
            PageRoutes.removedByRemoveRouteHolder(pageId)?.activity?.get()?.apply {
                this.finish()
            }
        }
    }
}
