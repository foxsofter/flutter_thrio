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

package com.foxsofter.flutter_thrio.navigator

import android.annotation.SuppressLint
import android.app.Activity
import android.app.Application
import android.os.Bundle
import com.foxsofter.flutter_thrio.extension.getPageId

@SuppressLint("StaticFieldLeak")
internal object ActivityDelegate : Application.ActivityLifecycleCallbacks {
    private const val TAG = "ActivityDelegate"

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
        PageRoutes.onActivityCreated(activity, savedInstanceState)

        NavigationController.onActivityCreated(activity, savedInstanceState)

        Log.i(TAG, "onActivityCreated: ${activity.intent.getPageId()}")
    }

    override fun onActivityStarted(activity: Activity) {
        PageRoutes.onActivityStarted(activity)

        NavigationController.onActivityStarted(activity)

        Log.i(TAG, "onActivityStarted: ${activity.intent.getPageId()}")
    }

    override fun onActivityPreResumed(activity: Activity) {
        PageRoutes.onActivityPreResumed(activity)

        Log.i(TAG, "onActivityPreResumed: ${activity.intent.getPageId()}")
    }

    override fun onActivityResumed(activity: Activity) {
        PageRoutes.onActivityResumed(activity)

        NavigationController.onActivityResumed(activity)

        Log.i(TAG, "onActivityResumed: ${activity.intent.getPageId()}")
    }

    override fun onActivityPrePaused(activity: Activity) {
        PageRoutes.onActivityPrePaused(activity)

        Log.i(TAG, "onActivityPrePaused: ${activity.intent.getPageId()}")
    }

    override fun onActivityPaused(activity: Activity) {
        PageRoutes.onActivityPaused(activity)

        NavigationController.onActivityPaused(activity)

        Log.i(TAG, "onActivityPaused: ${activity.intent.getPageId()}")
    }

    override fun onActivityStopped(activity: Activity) {
        PageRoutes.onActivityStopped(activity)

        NavigationController.onActivityStopped(activity)

        Log.i(TAG, "onActivityStopped: ${activity.intent?.getPageId()}")
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {
        PageRoutes.onActivitySaveInstanceState(activity, outState)

        NavigationController.onActivitySaveInstanceState(activity, outState)

        Log.i(TAG, "onActivitySaveInstanceState: ${activity.intent.getPageId()}")
    }

    override fun onActivityDestroyed(activity: Activity) {
        PageRoutes.onActivityDestroyed(activity)

        NavigationController.onActivityDestroyed(activity)

        Log.i(TAG, "onActivityDestroyed: ${activity.intent.getPageId()}")
    }
}