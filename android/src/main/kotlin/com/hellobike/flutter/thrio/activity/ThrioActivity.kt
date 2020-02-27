package com.hellobike.flutter.thrio.activity

import android.content.Intent
import com.hellobike.flutter.thrio.OnActionListener
import com.hellobike.flutter.thrio.navigator.NavigatorChannelCache
import com.hellobike.flutter.thrio.navigator.NavigatorController
import com.hellobike.thrio.OnNotifyListener
import com.hellobike.thrio.Result
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger

open class ThrioActivity : FlutterActivity(), OnActionListener, OnNotifyListener {

    private val channel by lazy {
        val messenger: BinaryMessenger = flutterEngine.run {
            requireNotNull(this) { "flutterEngine does not exist" }
            dartExecutor
        }
        NavigatorChannelCache.get(messenger.hashCode())
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.extras?.let { this.intent.putExtras(it) }
    }

    override fun onBackPressed() {
//        super.onBackPressed()
        NavigatorController.pop(context, true) {}
    }

    override fun onPush(url: String, index: Int, params: Map<String, Any>, animated: Boolean, result: Result) {
        channel.onPush(url, index, params, animated, result)
    }

    override fun onPop(url: String, index: Int, animated: Boolean, result: Result) {
        channel.onPop(url, index, animated, result)
    }

    override fun onRemove(url: String, index: Int, animated: Boolean, result: Result) {
        channel.onRemove(url, index, animated, result)
    }

    override fun onPopTo(url: String, index: Int, animated: Boolean, result: Result) {
        channel.onPopTo(url, index, animated, result)
    }

    override fun onNotify(url: String, index: Int, name: String, params: Map<String, Any>) {
        channel.onNotify(url, index, name, params)
    }

}