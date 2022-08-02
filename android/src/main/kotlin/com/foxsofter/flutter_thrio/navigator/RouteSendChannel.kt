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

import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.NullableBooleanCallback
import com.foxsofter.flutter_thrio.channel.ThrioChannel

internal class RouteSendChannel constructor(private val channel: ThrioChannel) {

    fun onPush(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("push", arguments) {
            if (it is Boolean) {
                result(it)
            } else {
                result(false)
            }
        }
    }

    fun onNotify(arguments: Map<String, Any?>?, result: BooleanCallback) {
        Log.i("Thrio", "onNotify channel data $arguments")
        channel.sendEvent("__onNotify__", arguments)
        result(true)
    }

    fun onPop(arguments: Map<String, Any?>?, result: NullableBooleanCallback) {
        channel.invokeMethod("pop", arguments) {
            if (it is Boolean) {
                result(it)
            } else {
                result(null)
            }
        }
    }

    fun onPopTo(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("popTo", arguments) {
            if (it is Boolean) {
                result(it)
            } else {
                result(false)
            }
        }
    }

    fun onRemove(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("remove", arguments) {
            if (it is Boolean) {
                result(it)
            } else {
                result(false)
            }
        }
    }
}