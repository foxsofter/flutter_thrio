/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Hellobike Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

package com.hellobike.flutter.thrio.navigator

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.os.Bundle

@SuppressLint("StaticFieldLeak")
internal object ActivityDelegate : Application.ActivityLifecycleCallbacks {

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {

        PageRoutes.restorePageId(activity, savedInstanceState)

        PageRoutes.setActivityReference(activity)
    }

    override fun onActivityStarted(activity: Activity) {
        if (NavigationController.routeAction == RouteAction.PUSH) {
            NavigationController.Push.doPush(activity)
        }
    }

    override fun onActivityPaused(activity: Activity) {
    }

    override fun onActivityResumed(activity: Activity) {

        PageRoutes.setActivityReference(activity)

        clearSystemDestroyed(activity)

        when (NavigationController.routeAction) {
            RouteAction.PUSH -> NavigationController.Push.doPush(activity)
            RouteAction.REMOVE -> NavigationController.Remove.didRemove(activity)
            RouteAction.POP_TO -> NavigationController.PopTo.didPopTo(activity)
        }
        NavigationController.Notify.doNotify(activity)
    }

    override fun onActivityStopped(activity: Activity?) {
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {

        PageRoutes.savePageId(activity, outState)

        setSystemDestroyed(activity)
    }

    override fun onActivityDestroyed(activity: Activity) {

        PageRoutes.unsetActivityReference(activity)

        if (isSystemDestroyed(activity)) {
            return
        }

        // 清空页面记录
        if (NavigationController.routeAction == RouteAction.NONE) {
            NavigationController.clearStack(activity)
            return
        }
    }

    private inline fun clearSystemDestroyed(activity: Activity) {
        activity.intent.removeExtra(THRIO_ACTIVITY_SAVE_KEY)
    }

    private inline fun setSystemDestroyed(activity: Activity) {
        activity.intent.putExtra(THRIO_ACTIVITY_SAVE_KEY, true)
    }

    private inline fun isSystemDestroyed(activity: Activity): Boolean {
        return activity.intent.getBooleanExtra(THRIO_ACTIVITY_SAVE_KEY, THRIO_ACTIVITY_SAVE_NONE)
    }
}