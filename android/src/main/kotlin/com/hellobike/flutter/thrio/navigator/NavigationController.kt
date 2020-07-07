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
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory.THRIO_ENGINE_FLUTTER_ENTRYPOINT_DEFAULT
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory.THRIO_ENGINE_NATIVE_ENTRYPOINT
import io.flutter.embedding.android.ThrioActivity

internal object NavigationController {

    var routeAction = RouteAction.NONE

    object Push {

        private var result: NullableIntCallback? = null
        private var poppedResult: NullableAnyCallback? = null

        fun push(context: Context,
                 url: String,
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

            val lastActivity = PageRoutes.lastActivity()
            var lastEntrypoint = lastActivity?.intent?.getEntrypoint()

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
            settings.isNested = PageRoutes.hasRoute(pageId)

            val route = PageRoute(settings, activity::class.java)
            route.fromEntryPoint = fromEntryPoint
            route.entryPoint = entrypoint
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

            PageRoutes.lastActivity()?.let { activity ->
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
        fun pop(params: Any? = null, animated: Boolean, result: BooleanCallback? = null) {
            if (routeAction != RouteAction.NONE) {
                result?.invoke(false)
                return
            }

            routeAction = RouteAction.POP

            PageRoutes.pop(params, animated) {
                result?.invoke(it)
                routeAction = RouteAction.NONE
            }
        }
    }

    object PopTo {

        fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback? = null) {
            if ((index != null && index < 0) || !PageRoutes.hasRoute(url, index)) {
                result?.invoke(false)
                return
            }

            PageRoutes.popTo(url, index, animated) {
                result?.invoke(it)
            }
        }

//        fun didPopTo(activity: Activity) {
//            val result = result
//            checkNotNull(result) { "result must not be null" }
//            val record = route
//            checkNotNull(record) { "popTo record not found" }
//            if (record.clazz != activity::class.java) {
//                return
//            }
//            val key = getPageId(activity)
//            if (PageRouteStack.getPageId(record) != key) {
//                activity.finish()
//                popTo(activity, record.url, record.index, record.animated, result)
//                return
//            }
//            routeAction = RouteAction.NONE
//            this.route = null
//            this.result = null
//            onPopTo(activity, record) {
//                if (it) {
//                    PageRouteStack.popTo(record)
//                    didNotify(activity, record)
//                }
//                result(it)
//            }
//        }

//        private fun onPopTo(activity: Activity, record: PageRoute, result: BooleanCallback) {
//            if (activity is ThrioActivity) {
//                activity.onPopTo(record.url, record.index, record.animated, result)
//                return
//            }
//            result(true)
//        }
    }

    object Remove {

        private var result: BooleanCallback? = null
        private var route: PageRoute? = null

        fun remove(context: Context,
                   url: String,
                   index: Int = 0,
                   animated: Boolean = true,
                   result: BooleanCallback) {
            if (routeAction != RouteAction.NONE) {
                result(false)
                return
            }

            if (!PageRouteStack.hasRoute()) {
                result(false)
                return
            }

            if (index < 0 || (index > 0 && !PageRouteStack.hasRoute(url, index))) {
                Log.e("Thrio", "action remove no route url $url index $index")
                result(false)
                return
            }
            val targetIndex = when (index) {
                NAVIGATION_ROUTE_INDEX_DEFAULT -> PageRouteStack.lastRoute(url)?.settings?.index
                else -> index
            }
            if (targetIndex == null) {
                result(false)
                return
            }

            val route = PageRouteStack.lastRoute(url, targetIndex)
            val last = PageRouteStack.lastRoute()
            if (last == route) {
                route.settings.animated = animated
            }
            val intent = Intent(context, route.clazz)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)

            context.startActivity(intent)

            routeAction = RouteAction.REMOVE

            this.route = route
            this.result = result
        }

        fun didRemove(activity: Activity) {
            val result = result
            checkNotNull(result) { "result must not be null" }
            val record = route
            checkNotNull(record) { "remove record not found" }
            check(PageRouteStack.hasRoute()) { "must has record" }
            val last = PageRouteStack.lastRoute()
            check(last.clazz == activity::class.java) {
                "activity is not match record ${record.clazz}"
            }
            routeAction = RouteAction.NONE
            this.route = null
            this.result = null
            if (last == record) {
                PageRouteStack.pop(record)
                onRemove(activity, record, result)
                return
            }
            record.removed = true
            result(true)
            return
        }

        private fun onRemove(activity: Activity, record: PageRoute, result: BooleanCallback) {
            if (activity is ThrioActivity) {
                activity.onRemove(record.url, record.index, record.animated, result)
                return
            }
            result(true)
        }
    }


    private fun String.getEntrypoint(): String = substring(1).split("/").firstOrNull()
            ?: throw IllegalArgumentException("entrypoint must not be null")


}
