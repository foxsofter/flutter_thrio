package com.hellobike.flutter.thrio

import android.app.Activity
import android.content.Context
import android.content.Intent

interface NavigationBuilder {

    fun getActivityClz(): Class<out Activity>

    fun navigation(context: Context, intent: Intent) {
        context.startActivity(intent)
    }
}