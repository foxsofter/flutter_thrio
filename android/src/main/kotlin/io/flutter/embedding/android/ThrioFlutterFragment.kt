/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2022 foxsofter
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

package io.flutter.embedding.android

import android.content.Context
import android.content.pm.PackageManager
import com.foxsofter.flutter_thrio.extension.getFieldNullableValue
import com.foxsofter.flutter_thrio.extension.setSuperFieldValue
import com.foxsofter.flutter_thrio.navigator.NavigationController
import com.foxsofter.flutter_thrio.navigator.ThrioNavigator
import io.flutter.Log

class ThrioFlutterFragment : FlutterFragment() {
    companion object {
        const val TAG = "ThrioFlutterFragment"
        var isInitialUrlPushed = false
    }

    internal class HookDelegateFactory : FlutterActivityAndFragmentDelegate.DelegateFactory {
        override fun createDelegate(host: FlutterActivityAndFragmentDelegate.Host): FlutterActivityAndFragmentDelegate {
            val d = ThrioFlutterViewDelegate(host)
            Log.i("ThrioFlutterViewDelegate", "createDelegate = ${d.hashCode()}")
            return d
        }
    }

    val engine: com.foxsofter.flutter_thrio.navigator.FlutterEngine?
        get() {
            val activity = requireActivity()
            if (activity !is ThrioFlutterFragmentActivity) {
                throw RuntimeException("ThrioFlutterFragment must be inside ThrioFlutterFragmentActivity")
            }
            return activity.engine
        }

    override fun onStart() {
        if (delegate != null) {
            val prevDelegate =
                flutterEngine!!.activityControlSurface.getFieldNullableValue<ThrioFlutterViewDelegate>(
                    "exclusiveActivity"
                )
            if (prevDelegate == null || delegate != prevDelegate) {
                (delegate!! as ThrioFlutterViewDelegate).reattach()
            }
        }
        super.onStart()
    }

    override fun onAttach(context: Context) {
        setSuperFieldValue("delegateFactory", HookDelegateFactory())
        super.onAttach(context)
    }

    override fun onBackPressed() {
        val activity = requireActivity()
        return activity.onBackPressed()
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()

        if (!isInitialUrlPushed && initialUrl?.isNotEmpty() == true) {
            isInitialUrlPushed = true
            NavigationController.Push.push(initialUrl!!, null, false) {}
        } else {
            val activity = requireActivity()
            Log.v(TAG, "onFlutterUiDisplayed ${hashCode()}, activity: ${activity.hashCode()}")
            NavigationController.Push.doPush(activity)
        }
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        val activity = requireActivity()
        if (activity !is ThrioFlutterFragmentActivity) {
            throw RuntimeException("ThrioFlutterFragment must be inside ThrioFlutterFragmentActivity")
        }
        return activity.shouldDestroyEngineWithHost()
    }

    override fun popSystemNavigator(): Boolean {
        ThrioNavigator.maybePop()
        return true
    }

    private var _initialUrl: String? = null

    private val initialUrl: String?
        get() {
            if (_initialUrl == null) {
                readInitialUrl()
            }
            return _initialUrl!!
        }

    private fun readInitialUrl() {
        val activity = requireActivity()
        val activityInfo =
            activity.packageManager.getActivityInfo(
                activity.componentName,
                PackageManager.GET_META_DATA
            )
        _initialUrl = if (activityInfo.metaData == null) "" else {
            activityInfo.metaData.getString("io.flutter.InitialUrl", "")
        }
    }
}