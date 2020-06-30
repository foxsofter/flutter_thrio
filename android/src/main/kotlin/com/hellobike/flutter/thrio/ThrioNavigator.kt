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

package com.hellobike.flutter.thrio

import android.app.Application
import android.content.Context
import com.hellobike.flutter.thrio.navigator.ActivitiesDelegate
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory.THRIO_ENGINE_NATIVE_ID
import com.hellobike.flutter.thrio.navigator.NavigationController

object ThrioNavigator {

    @JvmStatic
    @JvmOverloads
    fun push(context: Context,
             url: String,
             params: Any? = null,
             animated: Boolean = true,
             result: NullableIntCallback = {},
             poppedResult: NullableAnyCallback? = null
    ) = NavigationController.Push.push(context, url, params, animated, THRIO_ENGINE_NATIVE_ID, poppedResult, result)


    @JvmStatic
    @JvmOverloads
    fun pop(context: Context, params: Any? = null, animated: Boolean = true, result: BooleanCallback = {}) {
        NavigationController.Navigator.pop(context, params, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun remove(context: Context, url: String, index: Int, animated: Boolean = true, result: BooleanCallback = {}) {
        NavigationController.Remove.remove(context, url, index, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun popTo(context: Context, url: String, index: Int = 0,
              animated: Boolean = true, result: BooleanCallback = {}
    ) {
        NavigationController.PopTo.popTo(context, url, index, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun notify(url: String, index: Int = 0, name: String, params: Any?, result: BooleanCallback = {}) {
        NavigationController.notify(url, index, name, params, result)
    }

    internal fun init(context: Application) {
        FlutterEngineFactory.startup(context)
        context.registerActivityLifecycleCallbacks(ActivitiesDelegate)
    }
}


