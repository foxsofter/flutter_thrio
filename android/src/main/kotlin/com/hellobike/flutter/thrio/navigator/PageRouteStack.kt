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

import android.util.ArrayMap
import android.util.Log

internal object PageRouteStack {

    private const val PAGE_ROUTE_INDEX_START = 1

    /**
     * Key is page id, value is route stack of page.
     */
    private val routeStacks by lazy { ArrayMap<Int, MutableList<PageRoute>>() }

    /**
     * Key is url，value is last index.
     */
    private val lastRouteIndexes by lazy { ArrayMap<String, Int>() }

    /**
     * Called when the page is destroyed.
     */
    fun removeRoute(pageId: Int) {
        require(routeStacks.isNotEmpty()) { "stacks $routeStacks must not be empty" }
        val routeStack = routeStacks.remove(pageId)
        requireNotNull(routeStack) { "didn't find stack by this key $pageId" }
        repeat(routeStack.size) { pop(routeStack) }
    }

    /**
     * Get pageId of `route`.
     */
    fun getPageId(route: PageRoute): Int {
        for (it in routeStacks.size - 1 downTo 0) {
            val routeStack = routeStacks.valueAt(it)
            if (routeStack.isEmpty()) {
                continue
            }
            routeStack.lastOrNull { it.settings == route.settings } ?: continue
            return routeStacks.keyAt(it)
        }
        throw IllegalArgumentException("no match key")
    }

    /**
     * 入栈一条路由
     */
    fun push(pageId: Int, route: PageRoute) {
        require(pageId == routeStacks.keys.last()) { "Only allow the last page to push" }

        var routeStack = routeStacks[pageId]
        if (routeStack == null) {
            routeStack = mutableListOf()
            routeStacks[pageId] = routeStack
        }

        routeStack.add(route)

        lastRouteIndexes[route.settings.url] = route.settings.index

        Log.e("Thrio", "stack push url ${route.settings.url} index ${route.settings.index}")
    }

    /**
     * 移除顶部路由
     */
    fun pop(route: PageRoute) {
        require(routeStacks.isNotEmpty()) { "stacks $routeStacks must not be empty" }
        val pageId = routeStacks.keys.last()
        val routeStack = routeStacks[pageId]
        requireNotNull(routeStack) { "didn't find stack by this pageId $pageId" }
        require(routeStack.isNotEmpty()) { "stack $routeStack must not be empty" }
        require(routeStack.last() == route) { "only allow pop last route in stack" }
        pop(routeStack)
        if (routeStack.isEmpty()) {
            routeStacks.remove(pageId)
        }
    }

    /**
     * 关闭到指定路由
     */
    fun popTo(route: PageRoute) {
        require(routeStacks.isNotEmpty()) { "stacks $routeStacks must not be empty" }
        repeat(routeStacks.size) {
            val pageId = routeStacks.keys.last()
            val routeStack = routeStacks.values.last()
            repeat(routeStack.size) {
                val last = routeStack.last()
                if (route == last) {
                    return
                }
                pop(routeStack)
                if (routeStack.isEmpty()) {
                    routeStacks.remove(pageId)
                }
            }
        }
        throw IllegalArgumentException("no match record")
    }

    /**
     * If route equals null, delete all routes under pageId.
     */
    fun remove(pageId: Int, route: PageRoute? = null) {
        val routeStack = routeStacks[pageId] ?: throw IllegalArgumentException("pageId not exists")
        if (route == null) {
            repeat(routeStack.size) {
                routeStack.removeAt(it).removeNotify()
            }
        } else {
            if (routeStack.remove(route)) {
                if (routeStack.isEmpty()) {
                    lastRouteIndexes.remove(route.settings.url)
                } else {
                    lastRouteIndexes[route.settings.url] = routeStack.last().settings.index
                }
                route.removeNotify()
                Log.e("Thrio", "remove route url ${route.settings.url} index ${route.settings.index}")
            }
        }
    }

    fun hasRoute(): Boolean {
        return routeStacks.isNotEmpty() && routeStacks.any { it.value.isNotEmpty() }
    }

    fun hasRoute(pageId: Int): Boolean {
        return routeStacks[pageId]?.isNotEmpty() ?: false
    }

    fun hasRoute(url: String): Boolean {
        val v = lastRouteIndexes[url]
        v.apply { }
        return lastRouteIndexes[url].let { it != null && it >= PAGE_ROUTE_INDEX_START }
    }

    fun hasRoute(url: String, index: Int): Boolean {
        return lastRouteIndexes[url].let { it != null && it >= PAGE_ROUTE_INDEX_START && it >= index }
    }

    fun firstRoute(pageId: Int): PageRoute {
        val stack = routeStacks[pageId] ?: throw IllegalArgumentException("this key not in stack")
        require(stack.isNotEmpty()) { "stack is empty with key $pageId" }
        return stack.first()
    }

    fun lastRoute(): PageRoute {
        for (it in routeStacks.size - 1 downTo 0) {
            val routeStack = routeStacks.valueAt(it)
            if (routeStack.isEmpty()) {
                continue
            }
            return routeStack.last()
        }
        throw IllegalArgumentException("stack is empty")
    }

    fun lastRoute(pageId: Int): PageRoute {
        val stack = routeStacks[pageId] ?: throw IllegalArgumentException("this key not in stack")
        require(stack.isNotEmpty()) { "stack is empty with pageId $pageId" }
        return stack.last()
    }

    fun lastRoute(url: String, index: Int? = null): PageRoute {
        for (it in routeStacks.size - 1 downTo 0) {
            val stack = routeStacks.valueAt(it)
            if (stack.isEmpty()) {
                continue
            }
            return stack.lastOrNull {
                it.settings.url == url && (index == null || it.settings.index == index)
            } ?: continue
        }
        throw IllegalArgumentException("not found route with url: $url, index:$index")
    }

    fun allRoute(pageId: Int): List<PageRoute> {
        val stack = routeStacks[pageId] ?: throw IllegalArgumentException("pageId not exists")
        require(stack.isNotEmpty()) { "stack is empty with key $pageId" }
        return stack
    }

    fun allRoute(url: String): List<PageRoute> {
        val allRoutes = mutableListOf<PageRoute>()
        routeStacks.values.forEach { routeStack ->
            allRoutes.addAll(routeStack.takeWhile { route ->
                route.settings.url == url
            })
        }
        return allRoutes.toList()
    }


}