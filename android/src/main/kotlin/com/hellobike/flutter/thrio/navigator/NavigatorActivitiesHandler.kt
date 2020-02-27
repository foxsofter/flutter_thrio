package com.hellobike.flutter.thrio.navigator

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.os.Bundle

@SuppressLint("StaticFieldLeak")
internal object NavigatorActivitiesHandler : Application.ActivityLifecycleCallbacks {

    private const val KEY_THRIO_ACTIVITY_SAVE = "KEY_THRIO_ACTIVITY_SAVE"
    private const val THRIO_ACTIVITY_SAVE_NONE = false

    var activity: Activity? = null

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        NavigatorController.restoreData(activity, savedInstanceState)
    }

    override fun onActivityStarted(activity: Activity) {
    }

    override fun onActivityPaused(activity: Activity) {
    }

    override fun onActivityResumed(activity: Activity) {
        clearSystemDestroyed(activity)
        this.activity = activity
        if (NavigatorController.action == Action.NONE) {
            NavigatorController.didRemoveAndNotify(activity)
            return
        }
        /** push 添加stack key **/
        if (NavigatorController.action == Action.PUSH) {
            NavigatorController.didPush(activity)
            return
        }
        if (NavigatorController.action == Action.POP) {
            NavigatorController.didPop(activity)
            return
        }
        if (NavigatorController.action == Action.POP_TO) {
            NavigatorController.didPopTo(activity)
            return
        }
    }

    override fun onActivityStopped(activity: Activity?) {
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle?) {
        setSystemDestroyed(activity)
        NavigatorController.backUpData(activity, outState)
    }

    override fun onActivityDestroyed(activity: Activity) {
        if (this.activity == activity) {
            this.activity = null
        }
        if (isSystemDestroyed(activity)) {
            return
        }
        // 清空页面记录
        if (NavigatorController.action == Action.NONE) {
            NavigatorController.clearStack(activity)
        }
    }

    private fun clearSystemDestroyed(activity: Activity) {
        activity.intent.removeExtra(KEY_THRIO_ACTIVITY_SAVE)
    }

    private fun setSystemDestroyed(activity: Activity) {
        activity.intent.putExtra(KEY_THRIO_ACTIVITY_SAVE, true)
    }

    private fun isSystemDestroyed(activity: Activity): Boolean {
        return activity.intent.getBooleanExtra(KEY_THRIO_ACTIVITY_SAVE, THRIO_ACTIVITY_SAVE_NONE)
    }
}