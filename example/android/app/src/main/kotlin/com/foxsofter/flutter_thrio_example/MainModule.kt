package com.foxsofter.flutter_thrio_example

import android.app.Activity
import com.foxsofter.flutter_thrio.module.*
import com.foxsofter.flutter_thrio.navigator.FlutterIntentBuilder
import com.foxsofter.flutter_thrio.navigator.IntentBuilder
import io.flutter.embedding.android.ThrioFlutterFragmentActivity

object MainModule : ThrioModule(), ModuleIntentBuilder, ModuleJsonSerializer,
    ModuleJsonDeserializer {

    override fun onModuleInit(moduleContext: ModuleContext) {
        navigatorLogEnabled = true

        val people = People(
            mapOf(
                "name" to "foxsofter",
                "age" to 100,
                "sex" to "x"
            )
        )

        moduleContext["people_from_native"] = people

    }

    override fun onIntentBuilderRegister(moduleContext: ModuleContext) {
        setFlutterIntentBuilder(object : FlutterIntentBuilder(){
            override fun getActivityClz(): Class<out Activity> = ThrioFlutterFragmentActivity::class.java
        })

        registerIntentBuilder("/biz1/native1", object : IntentBuilder {
            override fun getActivityClz(): Class<out Activity> {
                return Native1Activity::class.java
            }
        })
        registerIntentBuilder("/biz2/native2", object : IntentBuilder {
            override fun getActivityClz(): Class<out Activity> {
                return Native2Activity::class.java
            }
        })
    }

    override fun onJsonSerializerRegister(moduleContext: ModuleContext) {
        registerJsonSerializer({ people -> people.toJson() }, People::class.java)
    }

    override fun onJsonDeserializerRegister(moduleContext: ModuleContext) {
        registerJsonDeserializer({ json -> People(json) }, People::class.java)
    }
}