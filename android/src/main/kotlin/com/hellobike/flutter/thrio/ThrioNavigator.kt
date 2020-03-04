// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

package com.hellobike.flutter.thrio

import android.content.Context
import com.hellobike.flutter.thrio.navigator.NavigatorBuilder
import com.hellobike.flutter.thrio.navigator.NavigatorController

object ThrioNavigator {

    @JvmStatic
    @JvmOverloads
    fun init(context: Context) {
        NavigatorController.init(context)
    }

    @JvmStatic
    @JvmOverloads
    fun push(
            context: Context,
            url: String, params: Map<String, Any> = emptyMap(),
            animated: Boolean = true, result: Result = {}
    ) {
        NavigatorController.push(context, url, params, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun pop(context: Context, animated: Boolean = true, result: Result = {}) {
        NavigatorController.pop(context, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun remove(context: Context, url: String, index: Int, animated: Boolean = true, result: Result = {}) {
        NavigatorController.remove(context, url, index, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun popTo(context: Context, url: String, index: Int = 0,
              animated: Boolean = true, result: Result = {}
    ) {
        NavigatorController.popTo(context, url, index, animated, result)
    }

    @JvmStatic
    @JvmOverloads
    fun notify(url: String, index: Int = 0, name: String, params: Map<String, Any>
               , result: Result = {}) {
        NavigatorController.notify(url, index, name, params, result)
    }

    @JvmStatic
    @JvmOverloads
    fun setPopDisabled(url: String, index: Int = 0, disable: Boolean, result: Result = {}) {
        NavigatorController.setPopDisabled(url, index, disable, result)
    }

    @JvmStatic
    @JvmOverloads
    fun registerNavigationBuilder(url: String, builder: NavigationBuilder) {
        NavigatorBuilder.registerNavigationBuilder(url, builder)
    }

    @JvmStatic
    @JvmOverloads
    fun removeNavigationBuilder(url: String) {
        NavigatorBuilder.unRegisterNavigationBuilder(url)
    }
}

typealias Result = (Boolean) -> Unit