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
import com.hellobike.flutter.thrio.NavigatorPageBuilder
import com.hellobike.flutter.thrio.ThrioNavigator
import com.hellobike.flutter.thrio.navigator.PageBuilders

open class ThrioModule {

    companion object {

        private val modules = HashMap<String, ThrioModule>()

        @JvmStatic
        fun init(context: Application, module: ThrioModule) {
            registerModule(module)
            initModule()
            ThrioNavigator.init(context)
        }

        private fun registerModule(module: ThrioModule) {
            val name = module::class.java.canonicalName
                    ?: throw IllegalArgumentException("module $module class no canonicalName")
            require(!modules.containsKey(name)) { "don't register Module twice" }
            modules[name] = module
            module.onModuleRegister()
        }

        private fun initModule() {
            modules.forEach { it.value.onPageRegister() }
            modules.forEach { it.value.onModuleInit() }
        }
    }

    protected open fun onModuleRegister() {

    }

    protected open fun onPageRegister() {

    }

    protected open fun onModuleInit() {

    }

    protected fun registerModule(module: ThrioModule) {
        ThrioModule.registerModule(module)
    }

    protected fun registerPageBuilder(url: String, builder: NavigatorPageBuilder): () -> Unit =
            PageBuilders.registerPageBuilder(url, builder)


//    private fun registerPageObserver() {
//
//    }
//
//    private fun registerRouteObserver() {
//
//    }
}