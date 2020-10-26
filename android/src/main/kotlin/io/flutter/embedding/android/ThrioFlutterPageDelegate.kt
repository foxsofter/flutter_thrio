package io.flutter.embedding.android

import android.annotation.SuppressLint
import android.app.Activity
import android.content.ComponentCallbacks2
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.annotation.VisibleForTesting
import androidx.lifecycle.Lifecycle
import com.hellobike.flutter.thrio.navigator.getPageId
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.platform.PlatformPlugin
import java.util.*

/**
 * Delegate that implements all Flutter logic that is the same between a [ThrioFlutterActivity] and
 * a [FlutterFragment].
 *
 *
 * **Why does this class exist?**
 *
 *
 * One might ask why an `Activity` and `Fragment` delegate needs to exist. Given that
 * a `Fragment` can be placed within an `Activity`, it would make more sense to use a
 * [FlutterFragment] within a [ThrioFlutterActivity].
 *
 *
 * The `Fragment` support library adds 100k of binary size to an app, and full-Flutter apps
 * do not otherwise require that binary hit. Therefore, it was concluded that Flutter must provide a
 * [ThrioFlutterActivity] based on the AOSP `Activity`, and an independent [ ] for add-to-app developers.
 *
 *
 * If a time ever comes where the inclusion of `Fragment`s in a full-Flutter app is no
 * longer deemed an issue, this class should be immediately decomposed between [ ] and [FlutterFragment] and then eliminated.
 *
 *
 * **Caution when modifying this class**
 *
 *
 * Any time that a "delegate" is created with the purpose of encapsulating the internal behaviors
 * of another object, that delegate is highly susceptible to degeneration. It is easy to tack new
 * responsibilities on to the delegate which would not otherwise be added to the original object. It
 * is also easy to begin hanging listeners and callbacks on a delegate object that likewise would
 * not be added to the original object. A delegate can quickly become a complex web of dependencies
 * and optional references that are very difficult to track.
 *
 *
 * Maintainers of this class should take care to only place code in this delegate that would
 * otherwise be placed in either [ThrioFlutterActivity] or [FlutterFragment], and in exactly
 * the same form. **Do not use this class as a convenient shortcut for any other
 * behavior.**
 */

// The ThrioFlutterActivity or FlutterFragment that is delegating most of its calls
// to this ThrioFlutterActivityAndFragmentDelegate.
internal class ThrioFlutterPageDelegate(private var host: ThrioFlutterActivity) {
    /**
     * Returns the [FlutterEngine] that is owned by this delegate and its host `Activity`
     * or `Fragment`.
     */  /* package */
    var flutterEngine: FlutterEngine? = null
        private set
    private var flutterSplashView: ThrioFlutterSplashView? = null
    private var flutterView: ThrioFlutterView? = null
    private var platformPlugin: PlatformPlugin? = null

    /**
     * Returns true if the host `Activity`/`Fragment` provided a `FlutterEngine`, as
     * opposed to this delegate creating a new one.
     */
    /* package */
    var isFlutterEngineFromHost = false
        private set
    private val flutterUiDisplayListener: FlutterUiDisplayListener = object : FlutterUiDisplayListener {
        override fun onFlutterUiDisplayed() {
            host.onFlutterUiDisplayed()
        }

        override fun onFlutterUiNoLongerDisplayed() {
            host.onFlutterUiNoLongerDisplayed()
        }
    }

    /**
     * Disconnects this `ThrioFlutterActivityAndFragmentDelegate` from its host `Activity` or
     * `Fragment`.
     *
     *
     * No further method invocations may occur on this `ThrioFlutterActivityAndFragmentDelegate`
     * after invoking this method. If a method is invoked, an exception will occur.
     *
     *
     * This method only clears out references. It does not destroy its [FlutterEngine]. The
     * behavior that destroys a [FlutterEngine] can be found in [.onDetach].
     */
    fun release() {
//        host = null
        flutterEngine = null
        flutterView = null
        platformPlugin = null
    }

    /**
     * Invoke this method from `Activity#onCreate(Bundle)` or `Fragment#onAttach(Context)`.
     *
     *
     * This method does the following:
     *
     *
     *
     *
     *
     *  1. Initializes the Flutter system.
     *  1. Obtains or creates a [FlutterEngine].
     *  1. Creates and configures a [PlatformPlugin].
     *  1. Attaches the [FlutterEngine] to the surrounding `Activity`, if desired.
     *  1. Configures the [FlutterEngine] via [       ][Host.configureFlutterEngine].
     *
     */
    fun onAttach(context: Context) {
        ensureAlive()

        // When "retain instance" is true, the FlutterEngine will survive configuration
        // changes. Therefore, we create a new one only if one does not already exist.
        if (flutterEngine == null) {
            setupFlutterEngine()
        }

        // Regardless of whether or not a FlutterEngine already existed, the PlatformPlugin
        // is bound to a specific Activity. Therefore, it needs to be created and configured
        // every time this Fragment attaches to a new Activity.
        // TODO(mattcarroll): the PlatformPlugin needs to be reimagined because it implicitly takes
        //                    control of the entire window. This is unacceptable for non-fullscreen
        //                    use-cases.
        platformPlugin = host.providePlatformPlugin(host.activity, flutterEngine!!)
        if (host.shouldAttachEngineToActivity()) {
            // Notify any plugins that are currently attached to our FlutterEngine that they
            // are now attached to an Activity.
            //
            // Passing this Fragment's Lifecycle should be sufficient because as long as this Fragment
            // is attached to its Activity, the lifecycles should be in sync. Once this Fragment is
            // detached from its Activity, that Activity will be detached from the FlutterEngine, too,
            // which means there shouldn't be any possibility for the Fragment Lifecycle to get out of
            // sync with the Activity. We use the Fragment's Lifecycle because it is possible that the
            // attached Activity is not a LifecycleOwner.
            Log.v(TAG, "Attaching FlutterEngine to the Activity that owns this Fragment.")
            flutterEngine
                    ?.activityControlSurface
                    ?.attachToActivity(host.activity, host.lifecycle)
        }
        host.configureFlutterEngine(flutterEngine!!)
    }

    /**
     * Obtains a reference to a FlutterEngine to back this delegate and its `host`.
     *
     *
     *
     *
     *
     * First, the `host` is asked if it would like to use a cached [FlutterEngine], and
     * if so, the cached [FlutterEngine] is retrieved.
     *
     *
     * Second, the `host` is given an opportunity to provide a [FlutterEngine] via
     * [Host.provideFlutterEngine].
     *
     *
     * If the `host` does not provide a [FlutterEngine], then a new [ ] is instantiated.
     */
    @VisibleForTesting
    fun setupFlutterEngine() {
        Log.v(TAG, "Setting up FlutterEngine.")

        // First, check if the host wants to use a cached FlutterEngine.
        val cachedEngineId = host.cachedEngineId
        if (cachedEngineId != null) {
            flutterEngine = FlutterEngineCache.getInstance()[cachedEngineId]
            isFlutterEngineFromHost = true
            checkNotNull(flutterEngine) {
                ("The requested cached FlutterEngine did not exist in the FlutterEngineCache: '"
                        + cachedEngineId
                        + "'")
            }
            return
        }

        // Second, defer to subclasses for a custom FlutterEngine.
        flutterEngine = host.provideFlutterEngine(host.context)
        if (flutterEngine != null) {
            isFlutterEngineFromHost = true
            return
        }

        // Our host did not provide a custom FlutterEngine. Create a FlutterEngine to back our
        // ThrioFlutterView.
        Log.v(TAG, "No preferred FlutterEngine was provided. Creating a new FlutterEngine for"
                + " this FlutterFragment.")
        flutterEngine = FlutterEngine(
                host.context,
                host.flutterShellArgs.toArray(),  /*automaticallyRegisterPlugins=*/
                false)
        isFlutterEngineFromHost = false
    }

    /**
     * Invoke this method from `Activity#onCreate(Bundle)` to create the content `View`,
     * or from `Fragment#onCreateView(LayoutInflater, ViewGroup, Bundle)`.
     *
     *
     * `inflater` and `container` may be null when invoked from an `Activity`.
     *
     *
     * This method:
     *
     *
     *  1. creates a new [flutterView] in a `View` hierarchy
     *  1. adds a [FlutterUiDisplayListener] to it
     *  1. attaches a [FlutterEngine] to the new [flutterView]
     *  1. returns the new `View` hierarchy
     *
     */
    @SuppressLint("ResourceType")
    fun onCreateView(
            inflater: LayoutInflater?, container: ViewGroup?, savedInstanceState: Bundle?): View {
        Log.v(TAG, "Creating ThrioFlutterView.")
        ensureAlive()
        flutterView = if (host.renderMode == RenderMode.surface) {
            val flutterSurfaceView = FlutterSurfaceView(
                    host.activity, host.transparencyMode == TransparencyMode.transparent)

            // Allow our host to customize FlutterSurfaceView, if desired.
            host.onFlutterSurfaceViewCreated(flutterSurfaceView)

            // Create the ThrioFlutterView that owns the FlutterSurfaceView.
            ThrioFlutterView(host.activity, flutterSurfaceView)
        } else {
            val flutterTextureView = FlutterTextureView(host.activity)

            // Allow our host to customize FlutterSurfaceView, if desired.
            host.onFlutterTextureViewCreated(flutterTextureView)

            // Create the ThrioFlutterView that owns the FlutterTextureView.
            ThrioFlutterView(host.activity, flutterTextureView)
        }

        // Add listener to be notified when Flutter renders its first frame.
        flutterView!!.addOnFirstFrameRenderedListener(flutterUiDisplayListener)
        flutterSplashView = ThrioFlutterSplashView(host.context)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            flutterSplashView!!.id = View.generateViewId()
        } else {
            // TODO(mattcarroll): Find a better solution to this ID. This is a random, static ID.
            // It might conflict with other Views, and it means that only a single FlutterSplashView
            // can exist in a View hierarchy at one time.
            flutterSplashView!!.id = 486947586
        }
        flutterSplashView!!.displayFlutterViewWithSplash(flutterView!!, host.provideSplashScreen())
        Log.v(TAG, "Attaching FlutterEngine to ThrioFlutterView.")
        flutterView!!.attachToFlutterEngine(flutterEngine!!)
        return flutterSplashView!!
    }

    fun onActivityCreated(bundle: Bundle?) {
        Log.v(TAG, "onActivityCreated. Giving plugins an opportunity to restore state.")
        ensureAlive()
        if (host.shouldAttachEngineToActivity()) {
            flutterEngine!!.activityControlSurface.onRestoreInstanceState(bundle)
        }
    }

    /**
     * Invoke this from `Activity#onStart()` or `Fragment#onStart()`.
     *
     *
     * This method:
     *
     *  1. Begins executing Dart code, if it is not already executing.
     *
     */
    fun onStart() {
        Log.v(TAG, "onStart()")
        ensureAlive()
        doInitialThrioFlutterViewRun()
    }

    /**
     * Starts running Dart within the ThrioFlutterView for the first time.
     *
     *
     * Reloading/restarting Dart within a given ThrioFlutterView is not supported. If this method is
     * invoked while Dart is already executing then it does nothing.
     *
     *
     * `flutterEngine` must be non-null when invoking this method.
     */
    private fun doInitialThrioFlutterViewRun() {
        // Don't attempt to start a FlutterEngine if we're using a cached FlutterEngine.
        if (host.cachedEngineId != null) {
            return
        }
        if (flutterEngine!!.dartExecutor.isExecutingDart) {
            // No warning is logged because this situation will happen on every config
            // change if the developer does not choose to retain the Fragment instance.
            // So this is expected behavior in many cases.
            return
        }
        Log.v(TAG,
                "Executing Dart entrypoint: "
                        + host.dartEntrypointFunctionName
                        + ", and sending initial route: "
                        + host.initialRoute)

        // The engine needs to receive the Flutter app's initial route before executing any
        // Dart code to ensure that the initial route arrives in time to be applied.
        flutterEngine!!.navigationChannel.setInitialRoute(host.initialRoute)

        // Configure the Dart entrypoint and execute it.
        val entrypoint = DartEntrypoint(
                host.appBundlePath, host.dartEntrypointFunctionName)
        Log.v(TAG, "executeDartEntrypoint: $entrypoint")
        flutterEngine!!.dartExecutor.executeDartEntrypoint(entrypoint)
    }

    /**
     * Invoke this from `Activity#onResume()` or `Fragment#onResume()`.
     *
     *
     * This method notifies the running Flutter app that it is "resumed" as per the Flutter app
     * lifecycle.
     */
    fun onResume() {
        Log.v(TAG, "onResume()")
        ensureAlive()
        flutterEngine?.let { engine ->
            engine.lifecycleChannel.appIsResumed()
            Log.v(TAG, "onResume: ${host.intent.getPageId()}")
            engine.activityControlSurface.attachToActivity(host.activity, host.lifecycle)
            if (host.shouldAttachEngineToActivity()) {
                flutterView?.reattachToFlutterEngine()
            }
        }
    }

    /**
     * Invoke this from `Activity#onPostResume()`.
     *
     *
     * A `Fragment` host must have its containing `Activity` forward this call so that
     * the `Fragment` can then invoke this method.
     *
     *
     * This method informs the [PlatformPlugin] that `onPostResume()` has run, which is
     * used to update system UI overlays.
     */
    // TODO(mattcarroll): determine why this can't be in onResume(). Comment reason, or move if
    // possible.
    fun onPostResume() {
        Log.v(TAG, "onPostResume()")
        ensureAlive()
        if (flutterEngine != null) {
            if (platformPlugin != null) {
                // TODO(mattcarroll): find a better way to handle the update of UI overlays than calling
                // through
                //                    to platformPlugin. We're implicitly entangling the Window, Activity,
                // Fragment,
                //                    and engine all with this one call.
                platformPlugin!!.updateSystemUiOverlays()
            }
        } else {
            Log.w(TAG, "onPostResume() invoked before FlutterFragment was attached to an Activity.")
        }
    }

    /**
     * Invoke this from `Activity#onPause()` or `Fragment#onPause()`.
     *
     *
     * This method notifies the running Flutter app that it is "inactive" as per the Flutter app
     * lifecycle.
     */
    fun onPause() {
        Log.v(TAG, "onPause()")
        ensureAlive()
        flutterEngine!!.lifecycleChannel.appIsInactive()
    }

    /**
     * Invoke this from `Activity#onStop()` or `Fragment#onStop()`.
     *
     *
     * This method:
     *
     *
     *
     *
     *
     *  1. This method notifies the running Flutter app that it is "paused" as per the Flutter app
     * lifecycle.
     *  1. Detaches this delegate's [FlutterEngine] from this delegate's [flutterView].
     *
     */
    fun onStop() {
        Log.v(TAG, "onStop()")
        ensureAlive()
        flutterEngine!!.lifecycleChannel.appIsPaused()
    }

    /**
     * Invoke this from `Activity#onDestroy()` or `Fragment#onDestroyView()`.
     *
     *
     * This method removes this delegate's [flutterView]'s [FlutterUiDisplayListener].
     */
    fun onDestroyView() {
        Log.v(TAG, "onDestroyView()")
        ensureAlive()
        flutterView!!.detachFromFlutterEngine()
        flutterView!!.removeOnFirstFrameRenderedListener(flutterUiDisplayListener)
    }

    fun onSaveInstanceState(bundle: Bundle?) {
        Log.v(TAG, "onSaveInstanceState. Giving plugins an opportunity to save state.")
        ensureAlive()
        if (host.shouldAttachEngineToActivity()) {
            flutterEngine!!.activityControlSurface.onSaveInstanceState(bundle!!)
        }
    }

    /**
     * Invoke this from `Activity#onDestroy()` or `Fragment#onDetach()`.
     *
     *
     * This method:
     *
     *
     *
     *
     *
     *  1. Detaches this delegate's [FlutterEngine] from its surrounding `Activity`, if
     * it was previously attached.
     *  1. Destroys this delegate's [PlatformPlugin].
     *  1. Destroys this delegate's [FlutterEngine] if [       ][Host.shouldDestroyEngineWithHost] ()} returns true.
     *
     */
    fun onDetach() {
        Log.v(TAG, "onDetach()")
        ensureAlive()

        // Give the host an opportunity to cleanup any references that were created in
        // configureFlutterEngine().
        host.cleanUpFlutterEngine(flutterEngine!!)
        if (host.shouldAttachEngineToActivity()) {
            // Notify plugins that they are no longer attached to an Activity.
            Log.v(TAG, "Detaching FlutterEngine from the Activity that owns this Fragment.")
            if (host.activity.isChangingConfigurations) {
                flutterEngine!!.activityControlSurface.detachFromActivityForConfigChanges()
            } else {
                flutterEngine!!.activityControlSurface.detachFromActivity()
            }
        }

        // Null out the platformPlugin to avoid a possible retain cycle between the plugin, this
        // Fragment,
        // and this Fragment's Activity.
        if (platformPlugin != null) {
            platformPlugin!!.destroy()
            platformPlugin = null
        }
        flutterEngine!!.lifecycleChannel.appIsDetached()

        // Destroy our FlutterEngine if we're not set to retain it.
        if (host.shouldDestroyEngineWithHost()) {
            flutterEngine!!.destroy()
            if (host.cachedEngineId != null) {
                FlutterEngineCache.getInstance().remove(host.cachedEngineId!!)
            }
            flutterEngine = null
        }
    }

    /**
     * Invoke this from [Activity.onBackPressed].
     *
     *
     * A `Fragment` host must have its containing `Activity` forward this call so that
     * the `Fragment` can then invoke this method.
     *
     *
     * This method instructs Flutter's navigation system to "pop route".
     */
    fun onBackPressed() {
        ensureAlive()
        if (flutterEngine != null) {
            Log.v(TAG, "Forwarding onBackPressed() to FlutterEngine.")
            flutterEngine?.navigationChannel?.popRoute()
        } else {
            Log.w(TAG, "Invoked onBackPressed() before FlutterFragment was attached to an Activity.")
        }
    }

    /**
     * Invoke this from [Activity.onRequestPermissionsResult] or `Fragment#onRequestPermissionsResult(int, String[], int[])`.
     *
     *
     * This method forwards to interested Flutter plugins.
     */
    fun onRequestPermissionsResult(
            requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        ensureAlive()
        if (flutterEngine != null) {
            Log.v(
                    TAG,
                    """
                        Forwarding onRequestPermissionsResult() to FlutterEngine:
                        requestCode: $requestCode
                        permissions: ${Arrays.toString(permissions)}
                        grantResults: ${Arrays.toString(grantResults)}
                        """.trimIndent())
            flutterEngine!!
                    .activityControlSurface
                    .onRequestPermissionsResult(requestCode, permissions, grantResults)
        } else {
            Log.w(
                    TAG,
                    "onRequestPermissionResult() invoked before FlutterFragment was attached to an Activity.")
        }
    }

    /**
     * Invoke this from `Activity#onNewIntent(Intent)`.
     *
     *
     * A `Fragment` host must have its containing `Activity` forward this call so that
     * the `Fragment` can then invoke this method.
     *
     *
     * This method forwards to interested Flutter plugins.
     */
    fun onNewIntent(intent: Intent) {
        ensureAlive()
        if (flutterEngine != null) {
            Log.v(TAG, "Forwarding onNewIntent() to FlutterEngine.")
            flutterEngine!!.activityControlSurface.onNewIntent(intent)
        } else {
            Log.w(TAG, "onNewIntent() invoked before FlutterFragment was attached to an Activity.")
        }
    }

    /**
     * Invoke this from `Activity#onActivityResult(int, int, Intent)` or `Fragment#onActivityResult(int, int, Intent)`.
     *
     *
     * This method forwards to interested Flutter plugins.
     */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        ensureAlive()
        if (flutterEngine != null) {
            Log.v(
                    TAG,
                    """
                        Forwarding onActivityResult() to FlutterEngine:
                        requestCode: $requestCode
                        resultCode: $resultCode
                        data: $data
                        """.trimIndent())
            flutterEngine!!.activityControlSurface.onActivityResult(requestCode, resultCode, data)
        } else {
            Log.w(TAG, "onActivityResult() invoked before FlutterFragment was attached to an Activity.")
        }
    }

    /**
     * Invoke this from `Activity#onUserLeaveHint()`.
     *
     *
     * A `Fragment` host must have its containing `Activity` forward this call so that
     * the `Fragment` can then invoke this method.
     *
     *
     * This method forwards to interested Flutter plugins.
     */
    fun onUserLeaveHint() {
        ensureAlive()
        if (flutterEngine != null) {
            Log.v(TAG, "Forwarding onUserLeaveHint() to FlutterEngine.")
            flutterEngine!!.activityControlSurface.onUserLeaveHint()
        } else {
            Log.w(TAG, "onUserLeaveHint() invoked before FlutterFragment was attached to an Activity.")
        }
    }

    /**
     * Invoke this from [Activity.onTrimMemory].
     *
     *
     * A `Fragment` host must have its containing `Activity` forward this call so that
     * the `Fragment` can then invoke this method.
     *
     *
     * This method sends a "memory pressure warning" message to Flutter over the "system channel".
     */
    fun onTrimMemory(level: Int) {
        ensureAlive()
        if (flutterEngine != null) {
            // Use a trim level delivered while the application is running so the
            // framework has a chance to react to the notification.
            if (level == ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW) {
                Log.v(TAG, "Forwarding onTrimMemory() to FlutterEngine. Level: $level")
                flutterEngine!!.systemChannel.sendMemoryPressureWarning()
            }
        } else {
            Log.w(TAG, "onTrimMemory() invoked before FlutterFragment was attached to an Activity.")
        }
    }

    /**
     * Invoke this from [Activity.onLowMemory].
     *
     *
     * A `Fragment` host must have its containing `Activity` forward this call so that
     * the `Fragment` can then invoke this method.
     *
     *
     * This method sends a "memory pressure warning" message to Flutter over the "system channel".
     */
    fun onLowMemory() {
        Log.v(TAG, "Forwarding onLowMemory() to FlutterEngine.")
        ensureAlive()
        flutterEngine!!.systemChannel.sendMemoryPressureWarning()
    }

    /**
     * Ensures that this delegate has not been [.release]'ed.
     *
     *
     * An `IllegalStateException` is thrown if this delegate has been [.release]'ed.
     */
    private fun ensureAlive() {
        checkNotNull(host) { "Cannot execute method on a destroyed ThrioFlutterActivityAndFragmentDelegate." }
    }

    /**
     * The [ThrioFlutterActivity] or [FlutterFragment] that owns this `ThrioFlutterActivityAndFragmentDelegate`.
     */
    /* package */
    internal interface Host : SplashScreenProvider, FlutterEngineProvider, FlutterEngineConfigurator {
        /** Returns the [Context] that backs the host [Activity] or `Fragment`.  */
        val context: Context

        /**
         * Returns the host [Activity] or the `Activity` that is currently attached to the
         * host `Fragment`.
         */
        val activity: Activity?

        /** Returns the [Lifecycle] that backs the host [Activity] or `Fragment`.  */
        val lifecycle: Lifecycle

        /** Returns the [FlutterShellArgs] that should be used when initializing Flutter.  */
        val flutterShellArgs: FlutterShellArgs

        /**
         * Returns the ID of a statically cached [FlutterEngine] to use within this delegate's
         * host, or `null` if this delegate's host does not want to use a cached [ ].
         */
        val cachedEngineId: String?

        /**
         * Returns true if the [FlutterEngine] used in this delegate should be destroyed when the
         * host/delegate are destroyed.
         *
         *
         * The default value is `true` in cases where `FlutterFragment` created its own
         * [FlutterEngine], and `false` in cases where a cached [FlutterEngine] was
         * provided.
         */
        fun shouldDestroyEngineWithHost(): Boolean

        /** Returns the Dart entrypoint that should run when a new [FlutterEngine] is created.  */
        val dartEntrypointFunctionName: String

        /** Returns the path to the app bundle where the Dart code exists.  */
        val appBundlePath: String

        /** Returns the initial route that Flutter renders.  */
        val initialRoute: String?

        /**
         * Returns the [RenderMode] used by the [flutterView] that displays the [ ]'s content.
         */
        val renderMode: RenderMode

        /**
         * Returns the [TransparencyMode] used by the [flutterView] that displays the [ ]'s content.
         */
        val transparencyMode: TransparencyMode

        override fun provideSplashScreen(): SplashScreen?

        /**
         * Returns the [FlutterEngine] that should be rendered to a [flutterView].
         *
         *
         * If `null` is returned, a new [FlutterEngine] will be created automatically.
         */
        override fun provideFlutterEngine(context: Context): FlutterEngine?

        /**
         * Hook for the host to create/provide a [PlatformPlugin] if the associated Flutter
         * experience should control system chrome.
         */
        fun providePlatformPlugin(
                activity: Activity?, flutterEngine: FlutterEngine): PlatformPlugin?

        /** Hook for the host to configure the [FlutterEngine] as desired.  */
        override fun configureFlutterEngine(flutterEngine: FlutterEngine)

        /**
         * Hook for the host to cleanup references that were established in [ ][.configureFlutterEngine] before the host is destroyed or detached.
         */
        override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine)

        /**
         * Returns true if the [FlutterEngine]'s plugin system should be connected to the host
         * [Activity], allowing plugins to interact with it.
         */
        fun shouldAttachEngineToActivity(): Boolean

        /**
         * Invoked by this delegate when the [FlutterSurfaceView] that renders the Flutter UI is
         * initially instantiated.
         *
         *
         * This method is only invoked if the [ ] is set to [ ][io.flutter.embedding.android.ThrioFlutterView.RenderMode.surface]. Otherwise, [ ][.onFlutterTextureViewCreated] is invoked.
         *
         *
         * This method is invoked before the given [FlutterSurfaceView] is attached to the
         * `View` hierarchy. Implementers should not attempt to climb the `View` hierarchy
         * or make assumptions about relationships with other `View`s.
         */
        fun onFlutterSurfaceViewCreated(flutterSurfaceView: FlutterSurfaceView)

        /**
         * Invoked by this delegate when the [FlutterTextureView] that renders the Flutter UI is
         * initially instantiated.
         *
         *
         * This method is only invoked if the [ ] is set to [ ][io.flutter.embedding.android.ThrioFlutterView.RenderMode.texture]. Otherwise, [ ][.onFlutterSurfaceViewCreated] is invoked.
         *
         *
         * This method is invoked before the given [FlutterTextureView] is attached to the
         * `View` hierarchy. Implementers should not attempt to climb the `View` hierarchy
         * or make assumptions about relationships with other `View`s.
         */
        fun onFlutterTextureViewCreated(flutterTextureView: FlutterTextureView)

        /** Invoked by this delegate when its [flutterView] starts painting pixels.  */
        fun onFlutterUiDisplayed()

        /** Invoked by this delegate when its [flutterView] stops painting pixels.  */
        fun onFlutterUiNoLongerDisplayed()
    }

    companion object {
        private const val TAG = "ThrioFlutterPageDelegate"
    }

}
