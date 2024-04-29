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

import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.NullableAnyCallback
import com.foxsofter.flutter_thrio.NullableIntCallback

object ThrioNavigator {
    @JvmStatic
    @JvmOverloads
    fun <T> push(
        url: String,
        params: T? = null,
        animated: Boolean = true,
        fromURL: String? = null,
        poppedResult: NullableAnyCallback? = null,
        result: NullableIntCallback = {}
    ) = NavigationController.Push.push<T>(
        url, params, animated,
        NAVIGATION_NATIVE_ENTRYPOINT,
        fromURL,
        null,
        null,
        NAVIGATION_ROUTE_PAGE_ID_NONE,
        poppedResult,
        result
    )

    @JvmStatic
    fun push(
        url: String,
        animated: Boolean = true,
        fromURL: String? = null,
        poppedResult: NullableAnyCallback? = null,
        result: NullableIntCallback = {}
    ) = NavigationController.Push.push(
        url, null, animated,
        NAVIGATION_NATIVE_ENTRYPOINT,
        fromURL,
        null,
        null,
        NAVIGATION_ROUTE_PAGE_ID_NONE,
        poppedResult,
        result
    )

    @JvmStatic
    @JvmOverloads
    fun <T> notify(
        url: String? = null,
        index: Int = 0,
        name: String,
        params: T? = null,
        result: BooleanCallback = {}
    ) = NavigationController.Notify.notify<T>(url, index, name, params, result)

    @JvmStatic
    fun notify(
        url: String? = null,
        index: Int = 0,
        name: String,
        result: BooleanCallback = {}
    ) = NavigationController.Notify.notify(url, index, name, null, result)

    @JvmStatic
    @JvmOverloads
    fun <T> maybePop(
        params: T? = null,
        animated: Boolean = true,
        result: BooleanCallback = {}
    ) = NavigationController.Pop.maybePop<T>(params, animated, result)

    @JvmStatic
    fun maybePop(animated: Boolean = true, result: BooleanCallback = {}) =
        NavigationController.Pop.maybePop(null, animated, result)
        
    @JvmStatic
    @JvmOverloads
    fun <T> pop(
        params: T? = null,
        animated: Boolean = true,
        result: BooleanCallback = {}
    ) = NavigationController.Pop.pop<T>(params, animated, result)

    @JvmStatic
    @JvmOverloads
    fun <T> popFlutter(
        params: T? = null,
        animated: Boolean = true,
        result: BooleanCallback = {}
    ) = NavigationController.Pop.popFlutter<T>(params, animated, result)

    @JvmStatic
    fun pop(animated: Boolean = true, result: BooleanCallback = {}) =
        NavigationController.Pop.pop(null, animated, result)

    @JvmStatic
    fun popFlutter(animated: Boolean = true, result: BooleanCallback = {}) =
        NavigationController.Pop.popFlutter(null, animated, result)

    @JvmStatic
    @JvmOverloads
    fun popTo(
        url: String,
        index: Int = 0,
        animated: Boolean = true,
        result: BooleanCallback = {}
    ) = NavigationController.PopTo.popTo(url, index, animated, result)

    @JvmStatic
    @JvmOverloads
    fun remove(
        url: String,
        index: Int = 0,
        animated: Boolean = true,
        result: BooleanCallback = {}
    ) = NavigationController.Remove.remove(url, index, animated, result)

    @JvmStatic
    @JvmOverloads
    fun lastRoute(url: String? = null): PageRoute? = PageRoutes.lastRoute(url)

    @JvmStatic
    @JvmOverloads
    fun allRoutes(url: String? = null): List<PageRoute> = PageRoutes.allRoutes(url)

    @JvmStatic
    @JvmOverloads
    fun isInitialRoute(url: String, index: Int = 0) =
        NavigationController.isInitialRoute(url, index)

}