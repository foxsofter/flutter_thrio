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

package com.foxsofter.flutter_thrio.module

import android.app.Application
import android.content.Context
import com.foxsofter.flutter_thrio.extension.canTransToFlutter
import com.foxsofter.flutter_thrio.navigator.*

open class ThrioModule {
    private val modules by lazy { mutableMapOf<Class<out ThrioModule>, ThrioModule>() }

    private var _moduleContext: ModuleContext? = null

    val moduleContext: ModuleContext get() = _moduleContext!!

    companion object {
        private val root by lazy { ThrioModule() }

        @JvmStatic
        fun init(module: ThrioModule, context: Application, multiEngineEnabled: Boolean = false) {
            FlutterEngineFactory.isMultiEngineEnabled = multiEngineEnabled
            context.registerActivityLifecycleCallbacks(ActivityDelegate)
            root._moduleContext = ModuleContext()
            root.registerModule(module, root.moduleContext)
            root.initModule()
            if (!FlutterEngineFactory.isMultiEngineEnabled) {
                root.startupFlutterEngine(context)
            }
        }
    }

    protected fun registerModule(module: ThrioModule, moduleContext: ModuleContext) {
        val jClazz = module::class.java
        require(!modules.containsKey(jClazz)) { "can not register Module twice" }
        modules[jClazz] = module
        module._moduleContext = moduleContext
        module.onModuleRegister(moduleContext)
    }

    protected fun initModule() {
        modules.values.forEach {
            it.onModuleInit(it.moduleContext)
            it.initModule()
        }
        modules.values.forEach {
            if (it is ModuleIntentBuilder) {
                it.onIntentBuilderRegister(it.moduleContext)
            }
        }
        modules.values.forEach {
            if (it is ModulePageObserver) {
                it.onPageObserverRegister(it.moduleContext)
            }
            if (it is ModuleRouteObserver) {
                it.onRouteObserverRegister(it.moduleContext)
            }
        }
        modules.values.forEach {
            if (it is ModuleJsonSerializer) {
                it.onJsonSerializerRegister(it.moduleContext)
            }
            if (it is ModuleJsonDeserializer) {
                it.onJsonDeserializerRegister(it.moduleContext)
            }
        }
    }

    protected open fun onModuleRegister(moduleContext: ModuleContext) {}

    protected open fun onModuleInit(moduleContext: ModuleContext) {}

    protected var navigatorLogEnabled
        get() = Log.navigatorLogging
        set(enabled) {
            Log.navigatorLogging = enabled
        }

    @JvmOverloads
    protected fun startupFlutterEngine(
        context: Context,
        entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
    ) {
        FlutterEngineFactory.startup(
            context, entrypoint,
            object : EngineReadyListener {
                override fun onReady(params: Any?) {
                    val nativeParams = moduleContext.params
                    val canTransParams = mutableMapOf<String, Any>()
                    for (param in nativeParams) {
                        val value = ModuleJsonSerializers.serializeParams(param.value)
                        if (value != null && value.canTransToFlutter()) {
                            canTransParams[param.key] = value
                        }
                    }
                    if (canTransParams.isNotEmpty()) {
                        FlutterEngineFactory.getEngine(entrypoint)?.moduleContextChannel?.apply {
                            invokeMethod("set", canTransParams)
                        }
                    }
                }
            })

    }
}