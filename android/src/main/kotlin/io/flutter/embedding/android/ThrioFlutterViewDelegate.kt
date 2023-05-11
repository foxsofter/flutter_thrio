/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2023 foxsofter
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

import com.foxsofter.flutter_thrio.extension.*
import io.flutter.Log
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.platform.PlatformPlugin
import java.util.*

internal class ThrioFlutterViewDelegate(host: Host) : FlutterActivityAndFragmentDelegate(host) {
    companion object {
        private const val TAG = "ThrioFlutterViewDelegate"
        private var lastResumeTimer: Timer? = null
    }

    private val host
        get() = getSuperFieldValue<Host>("host")

    private val flutterUiDisplayListener
        get() = getSuperFieldValue<FlutterUiDisplayListener>("flutterUiDisplayListener")

    private var platformPlugin
        get() = getSuperFieldNullableValue<PlatformPlugin>("platformPlugin")
        set(value) = setSuperFieldValue("platformPlugin", value)

    private var attached
        get() = getSuperFieldBoolean("isAttached")
        set(value) = setSuperFieldBoolean("isAttached", value)

    fun resume() {
        Log.i(TAG, "resume ${hashCode()} begin")
        val prevDelegate =
            flutterEngine!!.activityControlSurface.getFieldNullableValue<ThrioFlutterViewDelegate>("exclusiveActivity")
        if (prevDelegate != null) {
            if (lastResumeTimer != null) {
                lastResumeTimer!!.cancel();
                lastResumeTimer = null;
            }
            lastResumeTimer = Timer()
            lastResumeTimer!!.schedule(object : TimerTask() {
                override fun run() {
                    host.activity?.runOnUiThread {
                        platformPlugin = PlatformPlugin(host.activity!!, flutterEngine!!.platformChannel)
                        if (host.shouldDispatchAppLifecycleState()) {
                            flutterEngine!!.lifecycleChannel.appIsResumed()
                        }
                        updateSystemUiOverlays()
                    }
                }
            }, 500)
        }
        flutterEngine!!.activityControlSurface.attachToActivity(this, host.lifecycle)
        if (host.shouldAttachEngineToActivity() && flutterView != null && !flutterView!!.isAttachedToFlutterEngine) {
            println("$TAG resume ${hashCode()} flutterView attach")
            platformPlugin = PlatformPlugin(host.activity!!, flutterEngine!!.platformChannel)
            flutterView!!.addOnFirstFrameRenderedListener(flutterUiDisplayListener)
            flutterView!!.attachToFlutterEngine(flutterEngine!!)
            attached = true
        }
    }
}