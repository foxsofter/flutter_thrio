package com.foxsofter.flutter_thrio_example

import android.app.Application
import com.foxsofter.flutter_thrio.module.ThrioModule

class MainApp : Application() {
    override fun onCreate() {
        super.onCreate()

        ThrioModule.init(MainModule,this)
//        ThrioModule.init( MainModule, this, true)
    }
}

