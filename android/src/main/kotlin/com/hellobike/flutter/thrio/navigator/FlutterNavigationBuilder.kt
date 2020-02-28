package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import android.content.Context
import android.content.Intent
import com.hellobike.flutter.thrio.NavigationBuilder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.ThrioActivity

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