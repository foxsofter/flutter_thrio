package io.flutter.embedding.android

import com.foxsofter.flutter_thrio.extension.*
import io.flutter.Log
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.platform.PlatformPlugin
import java.util.*

internal class ThrioFlutterViewDelegate(host: Host) : FlutterActivityAndFragmentDelegate(host) {
    companion object {
        private const val TAG = "ThrioFlutterViewDelegate"
        private var lastResumeTimer: Timer? = null
    }

    private val host
        get() = getSuperFieldValue<Host>("host")

    private val flutterUiDisplayListener
        get() = getSuperFieldValue<FlutterUiDisplayListener>("flutterUiDisplayListener")

    private var platformPlugin
        get() = getSuperFieldNullableValue<PlatformPlugin>("platformPlugin")
        set(value) = setSuperFieldValue("platformPlugin", value)

    private var attached
        get() = getSuperFieldBoolean("isAttached")
        set(value) = setSuperFieldBoolean("isAttached", value)

//    private var engine
//        get() = getSuperFieldNullableValue<FlutterEngine>("flutterEngine")
//        set(value) = setSuperFieldValue("flutterEngine", value)

//    override fun onCreateView(
//        inflater: LayoutInflater?,
//        container: ViewGroup?,
//        savedInstanceState: Bundle?,
//        flutterViewId: Int,
//        shouldDelayFirstAndroidViewDraw: Boolean
//    ): View {
//        Log.v(TAG, "Creating ThrioFlutterView.")
//        callSuperMethod("ensureAlive")
//        if (host.renderMode == RenderMode.surface) {
//            val flutterSurfaceView = FlutterSurfaceView(
//                host.context, host.transparencyMode == TransparencyMode.transparent
//            )
//
//            // Allow our host to customize FlutterSurfaceView, if desired.
//            host.onFlutterSurfaceViewCreated(flutterSurfaceView)
//
//            // Create the FlutterView that owns the FlutterSurfaceView.
//            flutterView = ThrioFlutterView(host.context, RenderMode.surface)
//        } else {
//            val flutterTextureView = FlutterTextureView(host.context)
//            flutterTextureView.isOpaque = host.transparencyMode == TransparencyMode.opaque
//
//            // Allow our host to customize FlutterSurfaceView, if desired.
//            host.onFlutterTextureViewCreated(flutterTextureView)
//
//            // Create the FlutterView that owns the FlutterTextureView.
//            flutterView = ThrioFlutterView(host.context, RenderMode.texture)
//        }
//
//        // Add listener to be notified when Flutter renders its first frame.
//        flutterView!!.addOnFirstFrameRenderedListener(flutterUiDisplayListener)
//        Log.v(TAG, "Attaching FlutterEngine to FlutterView.")
//        flutterView!!.attachToFlutterEngine(flutterEngine!!)
//        flutterView!!.id = flutterViewId
//        val splashScreen = host.provideSplashScreen()
//        if (splashScreen != null) {
//            Log.w(
//                TAG,
//                "A splash screen was provided to Flutter, but this is deprecated. See"
//                        + " flutter.dev/go/android-splash-migration for migration steps."
//            )
//            val flutterSplashView = FlutterSplashView(host.context)
//            flutterSplashView.id = ViewUtils.generateViewId(
//                FLUTTER_SPLASH_VIEW_FALLBACK_ID
//            )
//            flutterSplashView.displayFlutterViewWithSplash(flutterView!!, splashScreen)
//            return flutterSplashView
//        }
//        if (shouldDelayFirstAndroidViewDraw) {
//            callSuperMethod("delayFirstAndroidViewDraw", flutterView)
//        }
//        return flutterView!!
//    }

    fun resume() {
        Log.i(TAG, "resume ${hashCode()} begin")
        val prevDelegate =
            flutterEngine!!.activityControlSurface.getFieldNullableValue<ThrioFlutterViewDelegate>("exclusiveActivity")
        if (prevDelegate != null) {
            if (lastResumeTimer != null) {
                lastResumeTimer!!.cancel();
                lastResumeTimer = null;
            }
            lastResumeTimer = Timer()
            lastResumeTimer!!.schedule(object : TimerTask() {
                override fun run() {
                    host.activity?.runOnUiThread {
                        platformPlugin = PlatformPlugin(host.activity!!, flutterEngine!!.platformChannel)
                        if (host.shouldDispatchAppLifecycleState()) {
                            flutterEngine!!.lifecycleChannel.appIsResumed()
                        }
                        updateSystemUiOverlays()
                    }
                }
            }, 500)
        }
        flutterEngine!!.activityControlSurface.attachToActivity(this, host.lifecycle)
        if (host.shouldAttachEngineToActivity() && flutterView != null && !flutterView!!.isAttachedToFlutterEngine) {
            println("$TAG resume ${hashCode()} flutterView attach")
            platformPlugin = PlatformPlugin(host.activity!!, flutterEngine!!.platformChannel)
            flutterView!!.addOnFirstFrameRenderedListener(flutterUiDisplayListener)
            flutterView!!.attachToFlutterEngine(flutterEngine!!)
            attached = true
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        Log.w(TAG, "onDestroyView ${hashCode()}")
    }

    override fun onDetach() {
        super.onDetach()
        Log.w(TAG, "onDetach ${hashCode()}")

    }
}