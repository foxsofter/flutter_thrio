package com.hellobike.flutter.thrio.navigator

import android.app.Activity

internal data class NavigatorPageRoute(val url: String, val index: Int, val clazz: Class<out Activity>) {
    var params: Map<String, Any> = emptyMap()
    var animated: Boolean = true
    var popDisabled: Boolean = false
    var removed: Boolean = false

    private val notifications: MutableMap<String, Map<String, Any>> = mutableMapOf()

    fun addNotify(name: String, params: Map<String, Any>) {
        notifications[name] = params
    }

    fun removeNotify(): Map<String, Map<String, Any>> {
        val result = notifications.toMap()
        notifications.clear()
        return result
    }
}