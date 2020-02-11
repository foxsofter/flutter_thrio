package com.hellobike.flutter.thrio

import android.support.annotation.NonNull
import android.util.Log
import com.hellobike.flutter.thrio.channel.ChannelManager
import com.hellobike.flutter.thrio.channel.ThrioChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
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
            val channel = ThrioChannel(registrar.context(), registrar.messenger())
            ChannelManager.cache(registrar.messenger().hashCode(), channel)
        }
    }

    private var channel: ThrioChannel? = null

    override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.e("Thrio", "onAttachedToEngine $binding")
        val channel = ThrioChannel(binding.applicationContext, binding.binaryMessenger)
        ChannelManager.cache(binding.binaryMessenger.hashCode(), channel)
        this.channel = channel
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        Log.e("Thrio", "onDetachedFromEngine $binding")
        ChannelManager.remove(binding.binaryMessenger.hashCode())
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.e("Thrio", "onAttachedToActivity ${binding.activity}")
//        channel?.activity = binding.activity
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.e("Thrio", "onReattachedToActivityForConfigChanges ${binding.activity}")
//        channel?.activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        Log.e("Thrio", "onDetachedFromActivity")
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.e("Thrio", "onDetachedFromActivityForConfigChanges")
    }


}
