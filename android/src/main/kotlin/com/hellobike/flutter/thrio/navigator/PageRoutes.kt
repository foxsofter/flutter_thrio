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
import android.os.Bundle
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableIntCallback
import java.lang.ref.WeakReference

internal object PageRoutes {

    private val activityHolders by lazy { mutableListOf<PageActivityHolder>() }

    private val removedActivityHolders by lazy { mutableListOf<PageActivityHolder>() }

    private val poppedToActivityHolders by lazy { mutableListOf<PageActivityHolder>() }

    fun lastActivityHolder(pageId: Int? = null): PageActivityHolder? = when (pageId) {
        null, NAVIGATION_PAGE_ID_NONE -> activityHolders.lastOrNull()
        else -> activityHolders.lastOrNull { it.pageId == pageId }
    }

    fun lastRemovedActivityHolder(pageId: Int): PageActivityHolder? {
        return removedActivityHolders.lastOrNull { it.pageId == pageId }
    }

    fun removeByPopToActivityHolder(url: String, index: Int?): List<PageActivityHolder>? {
        val activityHolder = activityHolders.lastOrNull { it.lastRoute(url, index) != null }
                ?: return null

        val activityHolderIndex = activityHolders.lastIndexOf(activityHolder)
        val activityHolders = mutableListOf<PageActivityHolder>()
        for (i in this.activityHolders.size - 1 downTo activityHolderIndex + 1) {
            activityHolders.add(this.activityHolders[i])
        }
        return activityHolders
    }

    fun lastActivityHolder(url: String, index: Int? = null): PageActivityHolder? {
        return activityHolders.lastOrNull { it.hasRoute(url, index) }
    }

    fun hasRoute(pageId: Int): Boolean {
        return activityHolders.any { it.pageId == pageId && it.hasRoute() }
    }

    fun hasRoute(url: String? = null, index: Int? = null): Boolean = activityHolders.any {
        it.hasRoute(url, index)
    }

    fun lastRoute(url: String? = null, index: Int? = null): PageRoute? {
        for (i in activityHolders.size - 1 downTo 0) {
            val activityHolder = activityHolders[i]
            return activityHolder.lastRoute(url, index) ?: continue
        }
        return null
    }

    fun lastRoute(pageId: Int): PageRoute? {
        val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
        return activityHolder?.lastRoute()
    }

    fun allRoute(url: String): List<PageRoute> {
        val allRoutes = mutableListOf<PageRoute>()
        for (i in activityHolders.size - 1 downTo 0) {
            val activityHolder = activityHolders[i]
            allRoutes.addAll(activityHolder.allRoute(url))
        }
        return allRoutes.toList()
    }

    fun push(activity: Activity, route: PageRoute, result: NullableIntCallback) {
        val entrypoint = activity.intent.getEntrypoint()
        val pageId = activity.intent.getPageId()
        var activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
        if (activityHolder == null) {
            activityHolder = PageActivityHolder(pageId, activity.javaClass, entrypoint).apply {
                this.activity = WeakReference(activity)
            }
            activityHolders.add(activityHolder)
        }
        activityHolder.push(route, result)
    }

    fun notify(url: String, index: Int? = null, name: String, params: Any?, result: BooleanCallback) {
        if (!hasRoute(url, index)) {
            result(false)
            return
        }

        var isMatch = false
        activityHolders.forEach { activityHolder ->
            activityHolder.notify(url, index, name, params) {
                if (it) isMatch = true
            }
        }
        result(isMatch)
    }

    fun pop(params: Any? = null, animated: Boolean, result: BooleanCallback) {
        val activityHolder = activityHolders.lastOrNull()
        if (activityHolder == null) {
            result(false)
            return
        }

        activityHolder.pop(params, animated) { it ->
            if (it) {
                if (!activityHolder.hasRoute()) {
                    activityHolders.remove(activityHolder)
                    activityHolder.activity?.get()?.let { activity ->
                        activity.finish()
                    }
                }
            }
            result(it)
        }
    }


    fun popTo(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val activityHolder = activityHolders.lastOrNull { it.lastRoute(url, index) != null }
        if (activityHolder == null || activityHolder.activity?.get() == null) {
            result(false)
            return
        }

        activityHolder.popTo(url, index, animated) {
            if (it) {
                val activityHolderIndex = activityHolders.lastIndexOf(activityHolder)
                val entrypoints = mutableListOf<String>()
                for (i in activityHolders.size - 1 downTo activityHolderIndex + 1) {
                    val poppedActivityHolder = activityHolders.removeAt(i)
                    poppedToActivityHolders.add(poppedActivityHolder)
                    entrypoints.add(poppedActivityHolder.entrypoint)
                }
                // 多引擎模式下的处理
                entrypoints.forEach { entrypoint ->
                    val lastActivityHolder = activityHolders.lastOrNull { activityHolder ->
                        activityHolder.entrypoint == entrypoint && activityHolder.hasRoute()
                    }
                    if (lastActivityHolder != null) {
                        val engine = FlutterEngineFactory.getEngine(entrypoint)
                        lastActivityHolder.lastRoute()?.let { route ->
                            engine?.onPopTo(route.settings.toArguments()) {}
                        }
                    }
                }
            }
            result(it)
        }

    }

    fun remove(url: String, index: Int?, animated: Boolean, result: BooleanCallback) {
        val activityHolder = activityHolders.lastOrNull { it.lastRoute(url, index) != null }
        if (activityHolder == null) {
            result(false)
            return
        }

        activityHolder.remove(url, index, animated) {
            if (it) {
                if (!activityHolder.hasRoute()) {
                    val activity = activityHolder.activity?.get()
                    if (activity == null) {
                        removedActivityHolders.add(activityHolder)
                    } else {
                        activity.finish()
                    }
                }
            }
            result(it)
        }
    }

    fun destroy(pageId: Int) {
        val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
        if (activityHolder != null) {
            activityHolders.remove(activityHolder)
        }
    }


    fun restorePageId(activity: Activity, savedInstanceState: Bundle?) {
        if (savedInstanceState == null) {
            return
        }
        val pageId = savedInstanceState.getInt(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            activity.intent.putExtra(NAVIGATION_PAGE_ID_KEY, pageId)
        } else {
            activity.intent.putExtra(NAVIGATION_PAGE_ID_KEY, activity.hashCode())
        }
    }

    fun savePageId(activity: Activity, outState: Bundle) {
        val pageId = activity.intent.getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            outState.putInt(NAVIGATION_PAGE_ID_KEY, pageId)
        }
    }

    fun setActivityReference(activity: Activity) {
        val pageId = activity.intent.getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
            activityHolder?.activity = WeakReference<Activity>(activity)
        }
    }

    fun unsetActivityReference(activity: Activity) {
        val pageId = activity.intent.getPageId()
        if (pageId != NAVIGATION_PAGE_ID_NONE) {
            val activityHolder = activityHolders.lastOrNull { it.pageId == pageId }
            if (activityHolder != null) {
                activityHolder.activity = null
            }
        }
    }


}