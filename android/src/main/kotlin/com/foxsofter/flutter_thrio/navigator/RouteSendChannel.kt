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
import com.foxsofter.flutter_thrio.IntCallback
import com.foxsofter.flutter_thrio.channel.ThrioChannel

internal class RouteSendChannel constructor(internal val channel: ThrioChannel) {

    fun onPush(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("push", arguments) {
            result(it == true)
        }
    }

    fun onNotify(arguments: Map<String, Any?>?, result: BooleanCallback) {
        Log.i("Thrio", "onNotify channel data $arguments")
        channel.sendEvent("__onNotify__", arguments)
        result(true)
    }

    fun onMaybePop(arguments: Map<String, Any?>?, result: IntCallback) {
        channel.invokeMethod("maybePop", arguments) {
            val r = if (it != null) it as Int else 0
            result(r)
        }
    }

    fun onPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("pop", arguments) {
            result(it == true)
        }
    }

    fun onPopTo(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("popTo", arguments) {
            result(it == true)
        }
    }

    fun onRemove(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("remove", arguments) {
            result(it == true)
        }
    }

    fun onReplace(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("replace", arguments) {
            result(it == true)
        }
    }

    fun onCanPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        channel.invokeMethod("canPop", arguments) {
            result(it == true)
        }
    }
}