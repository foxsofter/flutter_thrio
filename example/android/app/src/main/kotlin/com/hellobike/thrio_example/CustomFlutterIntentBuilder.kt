package com.hellobike.thrio_example

import android.app.Activity
import com.hellobike.flutter.thrio.navigator.FlutterIntentBuilder

object CustomFlutterIntentBuilder : FlutterIntentBuilder() {
    override fun getActivityClz(): Class<out Activity> = CustomFlutterActivity::class.java
}