package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import android.app.Application
import android.os.Bundle
import android.util.Log
import com.hellobike.flutter.thrio.record.FlutterRecord

internal object ActivityManager : Application.ActivityLifecycleCallbacks {

    private const val ACTION_NONE = "none"
    private const val ACTION_POP_TO = "popTo"

    private var action = ACTION_NONE

    override fun onActivityCreated(activity: Activity?, savedInstanceState: Bundle?) {
//        Log.e("Thrio", "create activity $activity")
    }

    override fun onActivityStarted(activity: Activity) {
        if (action == ACTION_POP_TO) {
            NavigationController.didPopTo(activity)
        }
    }

    override fun onActivityPaused(activity: Activity?) {
    }

    override fun onActivityResumed(activity: Activity) {
//        Log.e("Thrio", "resume activity $activity")
    }

    override fun onActivityStopped(activity: Activity?) {
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle?) {
        val url = activity.intent.getStringExtra("KEY_THRIO_URL")
        if (!url.isNullOrEmpty()) {
            activity.intent.putExtra("finish", false)
        }
    }

    override fun onActivityDestroyed(activity: Activity) {
//        Log.e("Thrio", "destroy activity $activity action $action")
        if (action == ACTION_NONE) {
            val url = activity.intent.getStringExtra("KEY_THRIO_URL")
            val finished = activity.intent.getBooleanExtra("finish", true)
            activity.intent.removeExtra("finish")
            if (!url.isNullOrEmpty() && finished) {
                FlutterRecord.pop()
            }
            return
        }
        if (action == ACTION_POP_TO && activity is ThrioActivity) {
            activity.popAll()
            return
        }
    }

    fun startPopTo() {
        action = ACTION_POP_TO
    }

    fun endPopTo() {
        action = ACTION_NONE
    }

}