package com.hellobike.thrio_example

import com.hellobike.flutter.thrio.channel.ThrioChannel
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory
import com.hellobike.flutter.thrio.navigator.getEntrypoint
import io.flutter.embedding.android.ThrioActivity
import io.flutter.embedding.engine.FlutterEngine
import java.util.*
import kotlin.concurrent.timerTask

class CustomFlutterActivity : ThrioActivity() {

    private var channel: ThrioChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineFactory.getEngine(intent.getEntrypoint())?.let {
            channel = ThrioChannel(intent.getEntrypoint(), "custom_thrio_channel")
            channel?.setupMethodChannel(it.flutterEngine.dartExecutor)
        }
    }

    override fun onResume() {
        super.onResume()
        Timer().schedule(timerTask {
            runOnUiThread {
                channel?.invokeMethod("sayHello")
            }
        }, 500)
    }
}