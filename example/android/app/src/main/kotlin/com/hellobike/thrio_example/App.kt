package com.hellobike.thrio_example

import android.app.Application
import com.hellobike.flutter.thrio.ThrioNavigator

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        ThrioNavigator.init(this)
    }
}