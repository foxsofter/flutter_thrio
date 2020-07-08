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

package com.hellobike.flutter.thrio.module

import android.app.Application
import android.content.Context
import com.hellobike.flutter.thrio.navigator.ThrioNavigator

open class ThrioModule {
    private val modules by lazy { mutableMapOf<Class<out ThrioModule>, ThrioModule>() }

    companion object {
        private val root by lazy { ThrioModule() }

        @JvmStatic
        fun init(context: Application, module: ThrioModule) {
            root.registerModule(context, module)
            root.initModule(context)
            ThrioNavigator.init(context)
        }
    }

    protected fun registerModule(context: Context, module: ThrioModule) {
        val jClazz = module::class.java
        require(!modules.containsKey(jClazz)) { "can not register Module twice" }
        modules[jClazz] = module
        module.onModuleRegister(context)
    }

    protected fun initModule(context: Context) {
        modules.values.forEach {
            it.onModuleInit(context)
            it.initModule(context)
        }
        modules.values.forEach {
            if (it is ModuleIntentBuilder) {
                it.onIntentBuilderRegister(context)
            }
        }
    }

    protected open fun onModuleRegister(context: Context) {}

    protected open fun onModuleInit(context: Context) {}
}