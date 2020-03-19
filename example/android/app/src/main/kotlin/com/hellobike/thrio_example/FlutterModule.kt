package com.hellobike.thrio_example

import android.app.Activity
import com.hellobike.flutter.thrio.NavigatorPageBuilder
import com.hellobike.flutter.thrio.module.ThrioModule

object FlutterModule : ThrioModule() {
    override fun onPageRegister() {
        registerPageBuilder("native1", object : NavigatorPageBuilder {
            override fun getActivityClz(url: String): Class<out Activity> {
                return Native1Activity::class.java
            }
        })
        registerPageBuilder("native2", object : NavigatorPageBuilder {
            override fun getActivityClz(url: String): Class<out Activity> {
                return Native2Activity::class.java
            }
        })
    }
}