package com.hellobike.flutter.thrio.activity

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.hellobike.thrio.NavigationBuilder
import com.hellobike.flutter.thrio.navigator.NavigatorController
import io.flutter.embedding.android.FlutterActivity

internal object FlutterNavigationBuilder : NavigationBuilder {
    override fun getActivityClz(url: String): Class<out Activity> =
            ThrioActivity::class.java

    override fun buildIntent(context: Context): Intent {
        return FlutterActivity
                .withCachedEngine(NavigatorController.THRIO_ENGINE_ID)
                .destroyEngineWithActivity(false)
                .build(context)
    }
}