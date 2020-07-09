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
import android.util.Log
import androidx.annotation.UiThread
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableAnyCallback
import com.hellobike.flutter.thrio.NullableIntCallback
import io.flutter.embedding.android.ThrioActivity

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

            var entrypoint = THRIO_ENGINE_NATIVE_ENTRYPOINT
            var isSingleTop = false

            val lastActivityHolder = PageRoutes.lastActivityHolder()
            val lastEntrypoint = lastActivityHolder?.entryPoint

            if (builder is FlutterIntentBuilder) {
                entrypoint = if (FlutterEngineFactory.isMultiEngineEnabled) {
                    url.getEntrypoint()
                } else {
                    THRIO_ENGINE_FLUTTER_ENTRYPOINT_DEFAULT
                }
                isSingleTop = lastEntrypoint == entrypoint
            }

            val settingsData = hashMapOf<String, Any>().also {
                it.putAll(settings.toArguments())
            }

            val context = lastActivityHolder?.activity?.get() ?: context!!

            val intent = builder.build(context, entrypoint).apply {
                if (!animated) {
                    addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                }
                if (isSingleTop) {
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                putExtra(NAVIGATION_ROUTE_SETTINGS_KEY, settingsData)
                putExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY, entrypoint)
                putExtra(NAVIGATION_ROUTE_FROM_ENTRYPOINT_KEY, fromEntrypoint)
            }

            routeAction = RouteAction.PUSH

            this.result = result
            this.poppedResult = poppedResult


            if (builder is FlutterIntentBuilder) {
                FlutterEngineFactory.startup(context, entrypoint, object : EngineReadyListener {
                    override fun onReady(params: Any?) {
                        if (params !is String || params != entrypoint) {
                            throw IllegalStateException("entrypoint must match.")
                        }
                        context.startActivity(intent)
                    }
                })
            } else {
                context.startActivity(intent)
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
            val settingsData = activity.intent.getSerializableExtra(NAVIGATION_ROUTE_SETTINGS_KEY).let {
                checkNotNull(it) { "push params not found" }
                it as Map<String, Any>
            }

            val settings = RouteSettings.fromArguments(settingsData)
            activity.intent.removeExtra(NAVIGATION_ROUTE_SETTINGS_KEY)

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
                    result?.invoke(null)
                } else {
                    result?.invoke(index)
                }
                routeAction = RouteAction.NONE
                result = null
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
                    val arguments = mapOf(
                            "__event_name__" to "__onNotify__",
                            "url" to route.settings.url,
                            "index" to route.settings.index,
                            "name" to it.key,
                            "params" to it.value
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
        @UiThread
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

        var result: BooleanCallback? = null
        var popToRoute: PageRoute? = null

        fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback? = null) {
            if (routeAction != RouteAction.NONE) {
                result?.invoke(false)
                return
            }

            this.result = result

            if (index != null && index < 0) {
                result(false)
                routeAction = RouteAction.NONE
                return
            }

            val popToRoute = PageRoutes.lastRoute(url, index)
            if (popToRoute == null || popToRoute == PageRoutes.lastRoute()) {
                result(false)
                routeAction = RouteAction.NONE
                return
            }

            routeAction = RouteAction.POP_TO
            popToRoute.settings.animated = animated
            this.popToRoute = popToRoute

            PageRoutes.lastActivityHolder()?.activity?.get()?.let { activity ->
                val builder = IntentBuilders.intentBuilders[popToRoute.settings.url]
                        ?: FlutterIntentBuilder
                val intent = builder.build(activity, popToRoute.entrypoint).let { intent ->
                    if (!animated) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                    }

                    intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    val settingsData = HashMap<String, Any>().also { it.putAll(popToRoute.settings.toArguments()) }
                    intent.putExtra(NAVIGATION_ROUTE_SETTINGS_KEY, settingsData)
                    intent.putExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY, popToRoute.entrypoint)
                    intent.putExtra(NAVIGATION_ROUTE_FROM_ENTRYPOINT_KEY, popToRoute.fromEntrypoint)
                }
                activity.startActivity(intent)
            }
        }

        fun doPopTo(activity: Activity) {
            if (routeAction != RouteAction.POP_TO) {
                result(false)
                return
            }

            if (popToRoute == null || popToRoute?.clazz != activity.javaClass) {
                result(false)
                routeAction = RouteAction.NONE
                return
            }

            routeAction = RouteAction.POPPING_TO

            popToRoute?.let { route ->
                PageRoutes.popTo(route.settings.url, route.settings.index, route.settings.animated) {
                    result(it)
                    routeAction = RouteAction.NONE
                }
            }
        }

        private fun result(success: Boolean) {
            result?.invoke(success)
            result = null
            popToRoute = null
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

    fun doDestroy(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_PAGE_ID_NONE) {
            return
        }
        PageRoutes.destroy(pageId)
    }

}
