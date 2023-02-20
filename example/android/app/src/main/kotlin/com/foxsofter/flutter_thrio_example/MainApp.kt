package com.foxsofter.flutter_thrio_example

import com.foxsofter.flutter_thrio.module.ThrioModule
import io.flutter.app.FlutterApplication

class MainApp : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()

        ThrioModule.init(MainModule,this)
//        ThrioModule.init( MainModule, this, true)
    }
}

