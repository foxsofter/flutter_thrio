package com.foxsofter.flutter_thrio

import com.foxsofter.flutter_thrio.navigator.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** FlutterThrioPlugin */
class FlutterThrioPlugin : FlutterPlugin {
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onAttachedToEngine")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.i(TAG, "onDetachedFromEngine")
    }

    companion object {
        private const val TAG = "FlutterThrioPlugin"
    }
}
