package com.hellobike.thrio_example

import android.app.ActivityManager
import android.content.Context

object Manager {
    fun activityManager(context: Context) {
        val manager: ActivityManager? = context.getSystemService(Context.ACTIVITY_SERVICE)?.let {
            if (it is ActivityManager) return@let it else null
        }
        manager
    }
}