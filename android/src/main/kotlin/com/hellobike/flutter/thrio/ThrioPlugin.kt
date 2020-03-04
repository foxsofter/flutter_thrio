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

package com.hellobike.flutter.thrio

import android.app.Application
import android.content.Context
import android.support.annotation.NonNull
import com.hellobike.flutter.thrio.navigator.NavigatorActivitiesHandler
import com.hellobike.flutter.thrio.navigator.NavigatorChannelCache
import com.hellobike.flutter.thrio.navigator.NavigatorSendChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry.Registrar

/** ThrioPlugin */
class ThrioPlugin : FlutterPlugin {

//
//    private var activity: Activity? = null
//    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
//        this.activity = binding.activity
//        Log.e("Thrio", "onAttached activity $activity")
//    }
//
//    override fun onDetachedFromActivity() {
//        Log.e("Thrio", "onDetached activity $activity")
//        this.activity = null
//    }
//
//    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//
//    }
//
//    override fun onDetachedFromActivityForConfigChanges() {
//
//    }

    companion object {
        // This static function is optional and equivalent to onAttachedToEngine. It supports the old
        // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
        // plugin registration via this function while apps migrate to use the new Android APIs
        // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
        //
        // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
        // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
        // depending on the user's project. onAttachedToEngine or registerWith must both be defined
        // in the same class.
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            init(registrar.context(), registrar.messenger())
        }

        private fun init(application: Context, binaryMessenger: BinaryMessenger) {
            val tag = binaryMessenger.hashCode()
            check(application is Application) { "application Context" }
            application.unregisterActivityLifecycleCallbacks(NavigatorActivitiesHandler)
            application.registerActivityLifecycleCallbacks(NavigatorActivitiesHandler)
            val channel = NavigatorSendChannel(binaryMessenger) {
                NavigatorActivitiesHandler.activity
                        ?: throw IllegalStateException("flutter didn't attached to activity")
            }
            NavigatorChannelCache.cache(tag, channel)
        }
    }

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        init(binding.applicationContext, binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        NavigatorChannelCache.remove(binding.binaryMessenger.hashCode())
    }
}
