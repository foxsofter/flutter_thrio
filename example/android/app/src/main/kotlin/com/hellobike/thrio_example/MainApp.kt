package com.hellobike.thrio_example

import android.app.Application
import com.hellobike.flutter.thrio.module.ThrioModule

class MainApp : Application() {
    override fun onCreate() {
        super.onCreate()

        ThrioModule.init(MainModule,this)
//        ThrioModule.init( MainModule, this, true)
    }
}

