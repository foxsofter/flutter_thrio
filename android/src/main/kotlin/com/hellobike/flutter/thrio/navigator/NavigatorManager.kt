package com.hellobike.flutter.thrio.navigator

import android.util.ArrayMap
import com.hellobike.flutter.thrio.PageBuilder

internal object NavigatorManager {
    private val handlers = ArrayMap<String, PageBuilder>()

    fun addPageBuilder(url: String, builder: PageBuilder) {
        handlers[url] = builder
    }

    fun hasPageBuilder(url: String): Boolean {
        return handlers.contains(url)
    }

    fun runPageBuilder(url: String) {
        handlers[url]?.openPage()
    }

}
