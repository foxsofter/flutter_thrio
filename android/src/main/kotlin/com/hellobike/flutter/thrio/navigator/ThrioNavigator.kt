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

import android.app.Application
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableAnyCallback
import com.hellobike.flutter.thrio.NullableIntCallback

object ThrioNavigator {

    @JvmStatic
    @JvmOverloads
    fun push(url: String,
             params: Any? = null,
             animated: Boolean = true,
             poppedResult: NullableAnyCallback? = null,
             result: NullableIntCallback = {}) {
        NavigationController.Push.push(url, params, animated,
                NAVIGATION_NATIVE_ENTRYPOINT, poppedResult, result)
    }


    @JvmStatic
    @JvmOverloads
    fun pop(params: Any? = null,
            animated: Boolean = true,
            result: BooleanCallback = {}) {
        NavigationController.Pop.pop(params, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun remove(url: String,
               index: Int = 0,
               animated: Boolean = true,
               result: BooleanCallback = {}) {
        NavigationController.Remove.remove(url, index, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun popTo(url: String,
              index: Int = 0,
              animated: Boolean = true,
              result: BooleanCallback = {}
    ) {
        NavigationController.PopTo.popTo(url, index, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun notify(url: String,
               index: Int = 0,
               name: String,
               params: Any?,
               result: BooleanCallback = {}) {
        NavigationController.Notify.notify(url, index, name, params, result)
    }

    internal fun init(context: Application) {
        FlutterEngineFactory.startup(context)
        context.registerActivityLifecycleCallbacks(ActivityDelegate)
    }
}


