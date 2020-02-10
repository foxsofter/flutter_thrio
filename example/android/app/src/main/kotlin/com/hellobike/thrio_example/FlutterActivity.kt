package com.hellobike.thrio_example

import android.os.Bundle
import android.support.annotation.NonNull
import com.hellobike.flutter.thrio.app.ThrioApp
import com.hellobike.flutter.thrio.navigator.ThrioActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class FlutterActivity : ThrioActivity() {
//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        flutterEngine.plugins[]
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
//    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.decorView.postDelayed({
            ThrioApp.pushWithFlutter("flutter1")
        }, 1000)
    }
}
