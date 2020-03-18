package com.hellobike.thrio_example

import android.app.Activity
import com.hellobike.flutter.thrio.NavigationBuilder
import com.hellobike.flutter.thrio.module.ThrioModule

class FlutterModule : ThrioModule() {
    override fun onPageRegister() {
        registerPageBuilder("native1", object : NavigationBuilder {
            override fun getActivityClz(url: String): Class<out Activity> {
                return Native1Activity::class.java
            }
        })
        registerPageBuilder("native2", object : NavigationBuilder {
            override fun getActivityClz(url: String): Class<out Activity> {
                return Native2Activity::class.java
            }
        })
    }
}