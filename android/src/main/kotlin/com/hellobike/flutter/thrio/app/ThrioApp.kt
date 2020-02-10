package com.hellobike.flutter.thrio.app

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.support.v4.app.ActivityCompat
import android.util.Log
import com.hellobike.flutter.thrio.channel.FlutterChannel
import com.hellobike.flutter.thrio.data.Record
import com.hellobike.flutter.thrio.navigator.ThrioActivity
import com.hellobike.flutter.thrio.record.FlutterRecord
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object ThrioApp : MethodChannel.MethodCallHandler {

    var activity: Activity? = null
    val topActivityClz: Class<*>?
        get() {
            val tasks = manager.getRunningTasks(1)
            if (tasks.isNullOrEmpty()) {
                return null
            }
            val topActivity = tasks[0]?.topActivity ?: return null
            return Class.forName(topActivity.className)
        }

    private lateinit var manager: ActivityManager
    private lateinit var channel: FlutterChannel

    fun register(context: Context, messenger: BinaryMessenger) {
        manager = ActivityCompat.getSystemService(context, ActivityManager::class.java)
                ?: throw IllegalAccessException("ActivityManager is null")
        this.channel = FlutterChannel(messenger, "__thrio_app__").apply {
            setMethodCallHandler(this@ThrioApp)
        }
    }

    fun onPush(record: Record) {
        val data = mapOf(
                "url" to record.url,
                "index" to record.index
        )
        channel.invokeMethod("__onPush__", data)
    }

    fun onPop(record: Record) {
        val data = mapOf(
                "url" to record.url,
                "index" to record.index
        )
        channel.invokeMethod("__onPop__", data)
    }

    private fun pushFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("ERROR 1", "ArgumentError url not found", "Please check argument Key or Type.")
            return
        }
        if (!isFlutterTop()) {
            Log.e("Thrio", "need start new Flutter page")
            return
        }
        val activity = activity
        if (activity == null) {
            Log.e("Thrio", "flutter activity null")
            return
        }
        ThrioActivity.push(activity, url)
        result.success(true)
    }

    private fun popFromFlutter(call: MethodCall, result: MethodChannel.Result) {
        if (!isFlutterTop()) {
            Log.e("Thrio", "need start new Flutter page")
            return
        }
        val activity = activity
        if (activity == null) {
            Log.e("Thrio", "flutter activity null")
            return
        }
        ThrioActivity.pop(activity)
        result.success(true)
    }

//    private fun didPopFromFlutter(call: MethodCall, result: MethodChannel.Result) {
//        val url = call.argument<String>("url")
//        if (url.isNullOrBlank()) {
//            result.error("ERROR 1", "ArgumentError url not found", "Please check argument Key or Type.")
//            return
//        }
//
//    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.e("Thrio", "flutter call method ${call.method}")
        when (call.method) {
            /** push **/
            "push" -> pushFromFlutter(call, result)
//            "didpush"->

            "pop" -> popFromFlutter(call, result)
//            "didPop" -> didPopFromFlutter(call, result)
//            "didRemove"->
            else -> result.notImplemented()
        }
    }


    private fun isFlutterTop(): Boolean {
        val topActivityClz = topActivityClz ?: throw IllegalArgumentException("topActivity is null")
        return ThrioActivity::class.java.isAssignableFrom(topActivityClz)
    }

}