package com.hellobike.thrio_example

import android.app.Activity
import android.content.Context
import com.hellobike.flutter.thrio.module.ModuleIntentBuilder
import com.hellobike.flutter.thrio.module.ThrioModule
import com.hellobike.flutter.thrio.navigator.IntentBuilder

object FlutterModule : ThrioModule(), ModuleIntentBuilder {

    override fun onPageRegister(context: Context) {
        registerIntentBuilder("native1", object : IntentBuilder {
            override fun getActivityClz(): Class<out Activity> {
                return Native1Activity::class.java
            }
        })
        registerIntentBuilder("native2", object : IntentBuilder {
            override fun getActivityClz(): Class<out Activity> {
                return Native2Activity::class.java
            }
        })
    }
}