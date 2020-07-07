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

import android.content.Intent


internal fun Intent.getPageId(): Int {
    return getIntExtra(NAVIGATION_PAGE_ID_KEY, NAVIGATION_PAGE_ID_NONE)
}

internal fun Intent.getEntrypoint(): String {
    return getStringExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY) ?: ""
}

internal fun Intent.getFromEntrypoint(): String {
    return getStringExtra(NAVIGATION_ROUTE_FROM_ENTRYPOINT_KEY) ?: ""
}

internal fun Intent.getRouteSettings(): RouteSettings {
    val data = getSerializableExtra(NAVIGATION_ROUTE_SETTINGS_KEY).let {
        checkNotNull(it) { "RouteSettings not found" }
        it as Map<String, Any>
    }
    return RouteSettings.fromArguments(data)
}