/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2021 foxsoter.
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

package com.foxsofter.flutter_thrio.extension

import android.content.Intent
import com.foxsofter.flutter_thrio.navigator.*

fun Intent.GetRouteUrl() = when (
    val routeSettings = getRouteSettings()) {
    null -> null
    else -> routeSettings.url
}

fun Intent.GetRouteIndex(): Int? = when (
    val routeSettings = getRouteSettings()) {
    null -> null
    else -> routeSettings.index
}

fun Intent.GetRouteAnimated(): Boolean? = when (
    val routeSettings = getRouteSettings()) {
    null -> null
    else -> routeSettings.animated
}

fun Intent.GetRouteParams(): Any? = when (
    val routeSettings = getRouteSettings()) {
    null -> null
    else -> routeSettings.params
}

internal fun Intent.getPageId(): Int {
    return getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
}

fun Intent.getEntrypoint(): String {
    return getStringExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY) ?: NAVIGATION_NATIVE_ENTRYPOINT
}

internal fun Intent.getFromEntrypoint(): String {
    return getStringExtra(NAVIGATION_ROUTE_FROM_ENTRYPOINT_KEY) ?: NAVIGATION_NATIVE_ENTRYPOINT
}

fun Intent.getRouteSettings(): RouteSettings? {
    val data = getSerializableExtra(NAVIGATION_ROUTE_SETTINGS_KEY)
    if (data != null && data is Map<*, *>) {
        @Suppress("UNCHECKED_CAST")
        return RouteSettings.fromArguments(data as Map<String, Any?>)
    }
    return null
}