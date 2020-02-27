package com.hellobike.flutter.thrio.navigator

import android.util.ArrayMap
import com.hellobike.thrio.NavigationBuilder
import com.hellobike.flutter.thrio.activity.FlutterNavigationBuilder

internal object NavigatorBuilder {
    private val builders = ArrayMap<String, NavigationBuilder>()
    private val flutterBuilder by lazy { FlutterNavigationBuilder }


    fun hasNavigationBuilder(url: String): Boolean {
        return builders.contains(url)
    }

    fun registerNavigationBuilder(url: String, builder: NavigationBuilder) {
        builders[url] = builder
    }

    fun getNavigationBuilder(url: String): NavigationBuilder {
        return builders[url] ?: flutterBuilder
    }

    fun unRegisterNavigationBuilder(url: String) {
        builders.remove(url)
    }

}

