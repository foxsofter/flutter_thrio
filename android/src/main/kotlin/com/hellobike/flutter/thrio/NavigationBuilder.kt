package com.hellobike.flutter.thrio

import android.app.Activity
import android.content.Context
import android.content.Intent


interface NavigationBuilder {

    fun getActivityClz(url: String): Class<out Activity>

    fun buildIntent(context: Context): Intent {
        return Intent()
    }

    fun navigation(context: Context, intent: Intent, params: Map<String, Any>) {
        context.startActivity(intent)
    }
}