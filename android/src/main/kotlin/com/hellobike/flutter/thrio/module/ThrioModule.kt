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