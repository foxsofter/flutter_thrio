package com.foxsofter.flutter_thrio_example

import com.foxsofter.flutter_thrio.channel.ThrioChannel
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import io.flutter.embedding.android.ThrioActivity
import io.flutter.embedding.engine.FlutterEngine

class CustomFlutterActivity : ThrioActivity() {

    private var channel: ThrioChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = ThrioChannel(intent.getEntrypoint(), "custom_thrio_channel")
        channel?.setupMethodChannel(flutterEngine.dartExecutor)
    }

    override fun onFlutterUiDisplayed() {
        super.onFlutterUiDisplayed()

        channel?.invokeMethod("sayHello")
    }

    // 当在根部时，重写以拦截是否需要再次点击返回键退出
    //
    override fun shouldMoveToBack(): Boolean {
        return true
    }
}