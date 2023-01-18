package io.flutter.embedding.android

import android.annotation.SuppressLint
import com.foxsofter.flutter_thrio.extension.getPageId
import com.foxsofter.flutter_thrio.navigator.NAVIGATION_ROUTE_PAGE_ID_NONE
import com.foxsofter.flutter_thrio.navigator.PageRoutes

open class ThrioRootFragmentActivity: ThrioFlutterFragmentActivity() {
    @SuppressLint("VisibleForTests")
    override fun createFlutterFragment(): FlutterFragment {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val holder = PageRoutes.lastRouteHolder(pageId)
            ?: throw throw IllegalStateException("holder must not be null")

        val backgroundMode = backgroundMode
        val renderMode = renderMode
        val transparencyMode =
            if (backgroundMode == FlutterActivityLaunchConfigs.BackgroundMode.opaque) TransparencyMode.opaque else TransparencyMode.transparent
        val shouldDelayFirstAndroidViewDraw = renderMode == RenderMode.surface
        return FlutterFragment.NewEngineFragmentBuilder(ThrioRootFragment::class.java)
            .dartEntrypoint(holder.entrypoint)
            .handleDeeplinking(shouldHandleDeeplinking())
            .renderMode(renderMode)
            .transparencyMode(transparencyMode)
            .shouldAttachEngineToActivity(shouldAttachEngineToActivity())
            .shouldDelayFirstAndroidViewDraw(shouldDelayFirstAndroidViewDraw)
            .build()
    }
}