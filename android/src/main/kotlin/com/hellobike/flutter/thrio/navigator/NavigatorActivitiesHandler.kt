// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

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
            NavigatorController.removeOrNotify(activity)
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
        if (NavigatorController.action == Action.REMOVE) {
            NavigatorController.didRemove(activity)
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
            return
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