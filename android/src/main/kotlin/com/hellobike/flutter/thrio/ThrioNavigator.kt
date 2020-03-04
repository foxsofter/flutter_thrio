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