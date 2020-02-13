package com.hellobike.flutter.thrio

import android.app.Activity
import android.app.Application
import android.content.Context
import android.support.annotation.NonNull
import android.util.Log
import com.hellobike.flutter.thrio.channel.ChannelManager
import com.hellobike.flutter.thrio.channel.ThrioChannel
import com.hellobike.flutter.thrio.navigator.ActivityManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry.Registrar

/** ThrioPlugin */
class ThrioPlugin : FlutterPlugin, ActivityAware {


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
            init(registrar.context(), registrar.messenger()) { registrar.activity() }
        }

        private fun init(application: Context, binaryMessenger: BinaryMessenger, activity: () -> Activity?) {
            if (application is Application) {
                application.unregisterActivityLifecycleCallbacks(ActivityManager)
                application.registerActivityLifecycleCallbacks(ActivityManager)
            }
            val channel = ThrioChannel(binaryMessenger, activity)
            ChannelManager.cache(binaryMessenger.hashCode(), channel)
        }
    }

    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        init(binding.applicationContext, binding.binaryMessenger) { activity }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        ChannelManager.remove(binding.binaryMessenger.hashCode())
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

}
