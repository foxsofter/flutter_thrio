package com.hellobike.flutter.thrio.module

import android.app.Application
import com.hellobike.flutter.thrio.NavigationBuilder
import com.hellobike.flutter.thrio.ThrioNavigator
import com.hellobike.flutter.thrio.navigator.NavigatorBuilder

open class ThrioModule {

    companion object {

        private val modules = HashMap<String, ThrioModule>()

        @JvmStatic
        fun init(context: Application, clz: Class<out ThrioModule>) {
            ThrioNavigator.init(context)
            registerModule(clz)
            initModule()
        }

        private fun registerModule(clz: Class<out ThrioModule>) {
            val name = clz.canonicalName
                    ?: throw IllegalArgumentException("class $clz no canonicalName")
            if (modules.containsKey(name)) {
                return
            }
            val module = clz.newInstance()
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

    protected fun registerModule(clz: Class<out ThrioModule>) {
        ThrioModule.registerModule(clz)
    }

    protected fun registerPageBuilder(url: String, builder: NavigationBuilder) {
        NavigatorBuilder.registerNavigationBuilder(url, builder)
    }

//    private fun registerPageObserver() {
//
//    }
//
//    private fun registerRouteObserver() {
//
//    }
}