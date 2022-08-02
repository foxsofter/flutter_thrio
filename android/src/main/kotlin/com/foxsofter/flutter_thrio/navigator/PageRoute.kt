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

package com.foxsofter.flutter_thrio.navigator

import android.app.Activity
import com.foxsofter.flutter_thrio.NullableAnyCallback

data class PageRoute(val settings: RouteSettings, val clazz: Class<out Activity>) {

    private val notifications: MutableMap<String, Any?> = mutableMapOf()

    var entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
    var fromEntrypoint: String = NAVIGATION_NATIVE_ENTRYPOINT

    var poppedResult: NullableAnyCallback? = null

    fun <T> addNotify(name: String, params: T?) {
        notifications[name] = params
    }

    fun removeNotify(): Map<String, Any?> {
        val result = notifications.toMap()
        notifications.clear()
        return result
    }
}