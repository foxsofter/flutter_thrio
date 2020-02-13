package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.ArrayMap
import com.hellobike.flutter.thrio.NavigationBuilder
import com.hellobike.flutter.thrio.record.FlutterRecord

internal object NavigationController {
    private const val KEY_THRIO_URL = "KEY_THRIO_URL"
    private const val KEY_THRIO_INDEX = "KEY_THRIO_INDEX"

    private var popToUrl = ""
    private var popToIndex = -1

    private val builders = ArrayMap<String, NavigationBuilder>()

    fun registerNavigationBuilder(url: String, builder: NavigationBuilder) {
        builders[url] = builder
    }

    fun hasNavigationBuilder(url: String): Boolean {
        return builders.contains(url)
    }

    fun navigation(context: Context, url: String) {
        val builder = builders[url] ?: return
        val record = FlutterRecord.push(url)
        val intent = Intent(context, builder.getActivityClz())
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        intent.putExtra(KEY_THRIO_URL, record.url)
        intent.putExtra(KEY_THRIO_INDEX, record.index)
        builder.navigation(context, intent)
    }

    fun popTo(context: Context, url: String, index: Int) {
        val builder = builders[url] ?: return
        val current = FlutterRecord.lastIndex(url)
        if (current < index) {
            return
        }
        val intent = Intent(context, builder.getActivityClz())
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        builder.navigation(context, intent)
        popToUrl = url
        popToIndex = index
        ActivityManager.startPopTo()
    }

    fun didPopTo(activity: Activity) {
        val popToUrl = popToUrl
        val popToIndex = popToIndex
        require(!(popToUrl.isBlank() || popToIndex == -1)) { "popTo url or index not found" }
        val url = activity.intent.getStringExtra(KEY_THRIO_URL)
        if (url != popToUrl) {
            return
        }
        val index = activity.intent.getIntExtra(KEY_THRIO_INDEX, -1)
        FlutterRecord.popTo(popToUrl, index)
        if (index <= popToIndex) {
            this.popToUrl = ""
            this.popToIndex = -1
            ActivityManager.endPopTo()
            return
        }
        activity.finish()
        FlutterRecord.pop()
        popTo(activity, url, popToIndex)
    }
}
