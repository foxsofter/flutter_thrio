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

package com.foxsofter.flutter_thrio.module

import android.app.Application
import com.foxsofter.flutter_thrio.extension.canTransToFlutter
import com.foxsofter.flutter_thrio.navigator.ActivityDelegate
import com.foxsofter.flutter_thrio.navigator.FlutterEngine
import com.foxsofter.flutter_thrio.navigator.FlutterEngineFactory
import com.foxsofter.flutter_thrio.navigator.Log

open class ThrioModule {
    companion object {
        internal val root by lazy { ThrioModule() }

        @JvmStatic
        fun init(module: ThrioModule, context: Application) {
            context.registerActivityLifecycleCallbacks(ActivityDelegate)
            root.moduleContext = ModuleContext()
            root.registerModule(module, root.moduleContext)
            root.initModule()
        }

        @JvmStatic
        fun initMultiEngine(module: ThrioModule, context: Application) {
            FlutterEngineFactory.isMultiEngineEnabled = true
            init(module, context)
        }
    }

    private val modules by lazy { mutableMapOf<Class<out ThrioModule>, ThrioModule>() }

    lateinit var moduleContext: ModuleContext private set

    protected fun registerModule(module: ThrioModule, moduleContext: ModuleContext) {
        val jClazz = module::class.java
        require(!modules.containsKey(jClazz)) { "can not register Module twice" }
        modules[jClazz] = module
        module.moduleContext = moduleContext
        module.onModuleRegister(moduleContext)
    }

    protected fun initModule() {
        modules.values.forEach { module ->
            module.onModuleInit(module.moduleContext)
            module.initModule()
        }
        modules.values.forEach { module ->
            if (module is ModuleIntentBuilder) {
                module.onIntentBuilderRegister(module.moduleContext)
            }
        }
        modules.values.forEach { module ->
            if (module is ModulePageObserver) {
                module.onPageObserverRegister(module.moduleContext)
            }
            if (module is ModuleRouteObserver) {
                module.onRouteObserverRegister(module.moduleContext)
            }
        }
        modules.values.forEach { module ->
            if (module is ModuleJsonSerializer) {
                module.onJsonSerializerRegister(module.moduleContext)
            }
            if (module is ModuleJsonDeserializer) {
                module.onJsonDeserializerRegister(module.moduleContext)
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

    internal fun syncModuleContext(engine: FlutterEngine) {
        val nativeParams = moduleContext.params
        val canTransParams = mutableMapOf<String, Any>()
        for (param in nativeParams) {
            val value = ModuleJsonSerializers.serializeParams(param.value)
            if (value != null && value.canTransToFlutter()) {
                canTransParams[param.key] = value
            }
        }
        if (canTransParams.isNotEmpty()) {
            engine.moduleContextChannel.apply {
                invokeMethod("set", canTransParams)
            }
        }
    }
}