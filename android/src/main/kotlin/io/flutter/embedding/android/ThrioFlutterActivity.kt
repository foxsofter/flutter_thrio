/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Hellobike Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

package io.flutter.embedding.android

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivityAndFragmentDelegate.Host
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterShellArgs
import io.flutter.plugin.platform.PlatformPlugin
import io.flutter.view.FlutterMain

// A number of methods in this class have the same implementation as FlutterFragmentActivity. These
// methods are duplicated for readability purposes. Be sure to replicate any change in this class in
// FlutterFragmentActivity, too.
open class ThrioFlutterActivity : Activity(), Host, LifecycleOwner {
    /**
     * Builder to create an `Intent` that launches a `ThrioFlutterActivity` with a new [ ] and the
     * desired configuration.
     */
    class NewEngineIntentBuilder(private val activityClass: Class<out ThrioFlutterActivity?>) {

        private var initialRoute = FlutterActivityLaunchConfigs.DEFAULT_INITIAL_ROUTE
        private var backgroundMode = FlutterActivityLaunchConfigs.DEFAULT_BACKGROUND_MODE

        /**
         * The initial route that a Flutter app will render in this [FlutterFragment], defaults to
         * "/".
         */
        fun initialRoute(initialRoute: String): NewEngineIntentBuilder {
            this.initialRoute = initialRoute
            return this
        }

        /**
         * The mode of `ThrioFlutterActivity`'s background, either [BackgroundMode.opaque] or
         * [BackgroundMode.transparent].
         *
         *
         * The default background mode is [BackgroundMode.opaque].
         *
         *
         * Choosing a background mode of [BackgroundMode.transparent] will configure the inner
         * [FlutterView] of this `ThrioFlutterActivity` to be configured with a [ ] to support transparency.
         * This choice has a non-trivial performance impact. A transparent background should only be
         * used if it is necessary for the app design being implemented.
         *
         *
         * A `ThrioFlutterActivity` that is configured with a background mode of [ ][BackgroundMode.transparent]
         * must have a theme applied to it that includes the following
         * property: `<item name="android:windowIsTranslucent">true</item>`.
         */
        fun backgroundMode(backgroundMode: BackgroundMode): NewEngineIntentBuilder {
            this.backgroundMode = backgroundMode.name
            return this
        }

        /**
         * Creates and returns an [Intent] that will launch a `ThrioFlutterActivity` with the
         * desired configuration.
         */
        fun build(context: Context): Intent {
            return Intent(context, activityClass)
                    .putExtra(FlutterActivityLaunchConfigs.EXTRA_INITIAL_ROUTE, initialRoute)
                    .putExtra(FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE, backgroundMode)
                    .putExtra(FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, true)
        }
    }

    /**
     * Builder to create an `Intent` that launches a `ThrioFlutterActivity` with an existing
     * [FlutterEngine] that is cached in [io.flutter.embedding.engine.FlutterEngineCache].
     */
    class CachedEngineIntentBuilder(private val activityClass: Class<out ThrioFlutterActivity?>,
                                    private val cachedEngineId: String) {

        private var destroyEngineWithActivity = false
        private var backgroundMode = FlutterActivityLaunchConfigs.DEFAULT_BACKGROUND_MODE

        /**
         * Returns true if the cached [FlutterEngine] should be destroyed and removed from the
         * cache when this `ThrioFlutterActivity` is destroyed.
         *
         *
         * The default value is `false`.
         */
        fun destroyEngineWithActivity(destroyEngineWithActivity: Boolean): CachedEngineIntentBuilder {
            this.destroyEngineWithActivity = destroyEngineWithActivity
            return this
        }

        /**
         * The mode of `ThrioFlutterActivity`'s background, either [BackgroundMode.opaque] or
         * [BackgroundMode.transparent].
         *
         *
         * The default background mode is [BackgroundMode.opaque].
         *
         *
         * Choosing a background mode of [BackgroundMode.transparent] will configure the inner
         * [FlutterView] of this `ThrioFlutterActivity` to be configured with a [ ] to support
         * transparency. This choice has a non-trivial performance impact. A transparent background
         * should only be used if it is necessary for the app design being implemented.
         *
         *
         * A `ThrioFlutterActivity` that is configured with a background mode of [ ]
         * [BackgroundMode.transparent] must have a theme applied to it that includes the following
         * property: `<item name="android:windowIsTranslucent">true</item>`.
         */
        fun backgroundMode(backgroundMode: BackgroundMode): CachedEngineIntentBuilder {
            this.backgroundMode = backgroundMode.name
            return this
        }

        /**
         * Creates and returns an [Intent] that will launch a `ThrioFlutterActivity` with the
         * desired configuration.
         */
        fun build(context: Context): Intent {
            return Intent(context, activityClass)
                    .putExtra(FlutterActivityLaunchConfigs.EXTRA_CACHED_ENGINE_ID, cachedEngineId)
                    .putExtra(FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY, destroyEngineWithActivity)
                    .putExtra(FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE, backgroundMode)
        }
    }

    // Delegate that runs all lifecycle and OS hook logic that is common between
    // ThrioFlutterActivity and ThrioFlutterFragment. See the FlutterActivityAndFragmentDelegate
    // implementation for details about why it exists.
    internal var delegate: ThrioFlutterPageDelegate? = null

    private val lifecycle by lazy { LifecycleRegistry(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        switchLaunchThemeForNormalTheme()
        super.onCreate(savedInstanceState)

        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_CREATE)
        delegate = ThrioFlutterPageDelegate(this)
        delegate?.onAttach(this)
        delegate?.onActivityCreated(savedInstanceState)

        configureWindowForTransparency()

        setContentView(createFlutterView())

        configureStatusBarForFullscreenFlutterExperience()
    }

    private fun switchLaunchThemeForNormalTheme() {
        try {
            val activityInfo = packageManager.getActivityInfo(componentName, PackageManager.GET_META_DATA)
            if (activityInfo.metaData != null) {
                val normalThemeRID = activityInfo.metaData.getInt(
                        FlutterActivityLaunchConfigs.NORMAL_THEME_META_DATA_KEY,
                        -1)
                if (normalThemeRID != -1) {
                    setTheme(normalThemeRID)
                }
            } else {
                Log.v(TAG, "Using the launch theme as normal theme.")
            }
        } catch (exception: PackageManager.NameNotFoundException) {
            Log.e(TAG,"Could not read meta-data for FlutterActivity. Using the launch theme as normal theme.")
        }
    }

    override fun provideSplashScreen(): SplashScreen? {
        val manifestSplashDrawable = splashScreenFromManifest
        return if (manifestSplashDrawable != null) {
            DrawableSplashScreen(manifestSplashDrawable)
        } else {
            null
        }
    }

    /**
     * Returns a [Drawable] to be used as a splash screen as requested by meta-data in the
     * `AndroidManifest.xml` file, or null if no such splash screen is requested.
     *
     *
     * See [FlutterActivityLaunchConfigs.SPLASH_SCREEN_META_DATA_KEY] for the meta-data key
     * to be used in a manifest file.
     */
    private val splashScreenFromManifest: Drawable?
        private get() = try {
            val activityInfo = packageManager.getActivityInfo(componentName, PackageManager.GET_META_DATA)
            val metadata = activityInfo.metaData
            val splashScreenId = metadata?.getInt(FlutterActivityLaunchConfigs.SPLASH_SCREEN_META_DATA_KEY)
                    ?: 0
            if (splashScreenId != 0)
                if (Build.VERSION.SDK_INT > Build.VERSION_CODES.LOLLIPOP)
                    resources.getDrawable(splashScreenId, theme)
                else
                    resources.getDrawable(splashScreenId)
            else null
        } catch (e: PackageManager.NameNotFoundException) {
            // This is never expected to happen.
            null
        }

    /**
     * Sets this `Activity`'s `Window` background to be transparent, and hides the status
     * bar, if this `Activity`'s desired [BackgroundMode] is [ ][BackgroundMode.transparent].
     *
     *
     * For `Activity` transparency to work as expected, the theme applied to this `Activity` must
     * include `<item name="android:windowIsTranslucent">true</item>`.
     */
    private fun configureWindowForTransparency() {
        val backgroundMode = backgroundMode
        if (backgroundMode == BackgroundMode.transparent) {
            window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        }
    }

    private fun createFlutterView(): View {
        return delegate!!.onCreateView(null, null, null)
    }

    private fun configureStatusBarForFullscreenFlutterExperience() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val window = window
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            window.statusBarColor = 0x40000000
            window.decorView.systemUiVisibility = PlatformPlugin.DEFAULT_SYSTEM_UI
        }
    }

    override fun onStart() {
        super.onStart()
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_START)
        delegate?.onStart()
    }

    override fun onResume() {
        super.onResume()
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        delegate?.onResume()
    }

    public override fun onPostResume() {
        super.onPostResume()
        delegate?.onPostResume()
    }

    override fun onPause() {
        super.onPause()
        delegate?.onPause()
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    }

    override fun onStop() {
        super.onStop()
        delegate?.onStop()
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        delegate?.onSaveInstanceState(outState)
    }

    override fun onDestroy() {
        super.onDestroy()
        delegate?.onDestroyView()
        delegate?.onDetach()
        lifecycle.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent) {
        delegate?.onActivityResult(requestCode, resultCode, data)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        delegate?.onNewIntent(intent)
    }

    override fun onBackPressed() {
        delegate?.onBackPressed()
    }

    override fun onRequestPermissionsResult(
            requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        delegate?.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    public override fun onUserLeaveHint() {
        delegate?.onUserLeaveHint()
    }

    override fun onTrimMemory(level: Int) {
        super.onTrimMemory(level)
        delegate?.onTrimMemory(level)
    }

    /**
     * [FlutterActivityAndFragmentDelegate.Host] method that is used by [ ] to obtain a `Context`
     * reference as needed.
     */
    override fun getContext(): Context {
        return this
    }

    /**
     * [FlutterActivityAndFragmentDelegate.Host] method that is used by [ ] to obtain an `Activity`
     * reference as needed. This reference is used by the delegate to instantiate a [FlutterView],
     * a [ ], and to determine if the `Activity` is changing configurations.
     */
    override fun getActivity(): Activity {
        return this
    }

    /**
     * [FlutterActivityAndFragmentDelegate.Host] method that is used by [ ] to obtain a `Lifecycle`
     * reference as needed. This reference is used by the delegate to provide Flutter plugins with
     * access to lifecycle events.
     */
    override fun getLifecycle(): Lifecycle {
        return lifecycle
    }

    /**
     * [FlutterActivityAndFragmentDelegate.Host] method that is used by [ ] to obtain Flutter shell
     * arguments when initializing
     * Flutter.
     */
    override fun getFlutterShellArgs(): FlutterShellArgs {
        return FlutterShellArgs.fromIntent(intent)
    }

    /**
     * Returns the ID of a statically cached [FlutterEngine] to use within this `ThrioFlutterActivity`,
     * or `null` if this `ThrioFlutterActivity` does not want to use a cached [FlutterEngine].
     */
    override fun getCachedEngineId(): String? {
        return intent.getStringExtra(FlutterActivityLaunchConfigs.EXTRA_CACHED_ENGINE_ID)
    }

    /**
     * Returns false if the [FlutterEngine] backing this `ThrioFlutterActivity` should outlive
     * this `ThrioFlutterActivity`, or true to be destroyed when the `ThrioFlutterActivity` is
     * destroyed.
     *
     *
     * The default value is `true` in cases where `ThrioFlutterActivity` created its own
     * [FlutterEngine], and `false` in cases where a cached [FlutterEngine] was
     * provided.
     */
    override fun shouldDestroyEngineWithHost(): Boolean {
        val explicitDestructionRequested = intent.getBooleanExtra(
                FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY,
                false)
        return if (cachedEngineId != null || delegate!!.isFlutterEngineFromHost) {
            // Only destroy a cached engine if explicitly requested by app developer.
            explicitDestructionRequested
        } else {
            // If this Activity created the FlutterEngine, destroy it by default unless
            // explicitly requested not to.
            intent.getBooleanExtra(FlutterActivityLaunchConfigs.EXTRA_DESTROY_ENGINE_WITH_ACTIVITY,
                    true)
        }
    }

    /**
     * The Dart entrypoint that will be executed as soon as the Dart snapshot is loaded.
     *
     *
     * This preference can be controlled by setting a `<meta-data>` called [ ]
     * [FlutterActivityLaunchConfigs.DART_ENTRYPOINT_META_DATA_KEY] within the Android manifest
     * definition for this `ThrioFlutterActivity`.
     *
     *
     * Subclasses may override this method to directly control the Dart entrypoint.
     */
    override fun getDartEntrypointFunctionName(): String {
        return try {
            val activityInfo = packageManager.getActivityInfo(componentName, PackageManager.GET_META_DATA)
            val metadata = activityInfo.metaData
            val desiredDartEntrypoint = metadata?.getString(FlutterActivityLaunchConfigs.DART_ENTRYPOINT_META_DATA_KEY)
            desiredDartEntrypoint ?: FlutterActivityLaunchConfigs.DEFAULT_DART_ENTRYPOINT
        } catch (e: PackageManager.NameNotFoundException) {
            FlutterActivityLaunchConfigs.DEFAULT_DART_ENTRYPOINT
        }
    }

    /**
     * The initial route that a Flutter app will render upon loading and executing its Dart code.
     *
     *
     * This preference can be controlled with 2 methods:
     *
     *
     *  1. Pass a boolean as [FlutterActivityLaunchConfigs.EXTRA_INITIAL_ROUTE] with the launching
     *  `Intent`, or
     *  1. Set a `<meta-data>` called [][FlutterActivityLaunchConfigs.INITIAL_ROUTE_META_DATA_KEY]
     *  for this `Activity` in the Android manifest.
     *
     *
     * If both preferences are set, the `Intent` preference takes priority.
     *
     *
     * The reason that a `<meta-data>` preference is supported is because this `Activity` might be
     * the very first `Activity` launched, which means the developer won't have control over the
     * incoming `Intent`.
     *
     *
     * Subclasses may override this method to directly control the initial route.
     */
    override fun getInitialRoute(): String {
        if (intent.hasExtra(FlutterActivityLaunchConfigs.EXTRA_INITIAL_ROUTE)) {
            return intent.getStringExtra(FlutterActivityLaunchConfigs.EXTRA_INITIAL_ROUTE)
        }
        return try {
            val activityInfo = packageManager.getActivityInfo(componentName, PackageManager.GET_META_DATA)
            val metadata = activityInfo.metaData
            val desiredInitialRoute = metadata?.getString(FlutterActivityLaunchConfigs.INITIAL_ROUTE_META_DATA_KEY)
            desiredInitialRoute ?: FlutterActivityLaunchConfigs.DEFAULT_INITIAL_ROUTE
        } catch (e: PackageManager.NameNotFoundException) {
            FlutterActivityLaunchConfigs.DEFAULT_INITIAL_ROUTE
        }
    }

    /**
     * The path to the bundle that contains this Flutter app's resources, e.g., Dart code snapshots.
     *
     *
     * When this `ThrioFlutterActivity` is run by Flutter tooling and a data String is included in
     * the launching `Intent`, that data String is interpreted as an app bundle path.
     *
     *
     * By default, the app bundle path is obtained from [FlutterMain.findAppBundlePath].
     *
     *
     * Subclasses may override this method to return a custom app bundle path.
     */
    override fun getAppBundlePath(): String {
        // If this Activity was launched from tooling, and the incoming Intent contains
        // a custom app bundle path, return that path.
        // TODO(mattcarroll): determine if we should have an explicit FlutterTestActivity instead of
        // conflating.
        if (isDebuggable && Intent.ACTION_RUN == intent.action) {
            val appBundlePath = intent.dataString
            if (appBundlePath != null) {
                return appBundlePath
            }
        }

        // Return the default app bundle path.
        // TODO(mattcarroll): move app bundle resolution into an appropriately named class.
        return FlutterMain.findAppBundlePath()
    }

    /**
     * Returns true if Flutter is running in "debug mode", and false otherwise.
     *
     *
     * Debug mode allows Flutter to operate with hot reload and hot restart. Release mode does not.
     */
    private val isDebuggable: Boolean
        private get() = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0

    /**
     * [FlutterActivityAndFragmentDelegate.Host] method that is used by [ ] to obtain the desired
     * [RenderMode] that should be used when instantiating a [FlutterView].
     */
    override fun getRenderMode(): RenderMode {
        return if (backgroundMode == BackgroundMode.opaque) RenderMode.surface else RenderMode.texture
    }

    /**
     * [FlutterActivityAndFragmentDelegate.Host] method that is used by [ ] to obtain the desired
     * [TransparencyMode] that should be used when instantiating a [FlutterView].
     */
    override fun getTransparencyMode(): TransparencyMode {
        return if (backgroundMode == BackgroundMode.opaque) TransparencyMode.opaque else TransparencyMode.transparent
    }

    /**
     * The desired window background mode of this `Activity`, which defaults to [ ][BackgroundMode.opaque].
     */
    private val backgroundMode: BackgroundMode
        get() {
            return if (intent.hasExtra(FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE)) {
                BackgroundMode.valueOf(intent.getStringExtra(FlutterActivityLaunchConfigs.EXTRA_BACKGROUND_MODE))
            } else {
                BackgroundMode.opaque
            }
        }

    /**
     * Hook for subclasses to easily provide a custom [FlutterEngine].
     *
     *
     * This hook is where a cached [FlutterEngine] should be provided, if a cached [ ] is desired.
     */
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        // No-op. Hook for subclasses.
        return null
    }

    /**
     * Hook for subclasses to obtain a reference to the [FlutterEngine] that is owned by this
     * `ThrioFlutterActivity`.
     */
    protected val flutterEngine: FlutterEngine?
        protected get() = delegate?.flutterEngine

    override fun providePlatformPlugin(activity: Activity?, flutterEngine: FlutterEngine): PlatformPlugin? {
        return if (activity != null) {
            PlatformPlugin(getActivity(), flutterEngine.platformChannel)
        } else {
            null
        }
    }

    /**
     * Hook for subclasses to easily configure a `FlutterEngine`.
     *
     *
     * This method is called after [.provideFlutterEngine].
     *
     *
     * All plugins listed in the app's pubspec are registered in the base implementation of this
     * method. To avoid automatic plugin registration, override this method without invoking super().
     * To keep automatic plugin registration and further configure the flutterEngine, override this
     * method, invoke super(), and then configure the flutterEngine as desired.
     */
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        registerPlugins(flutterEngine)
    }

    /**
     * Hook for the host to cleanup references that were established in [ ][.configureFlutterEngine]
     * before the host is destroyed or detached.
     *
     *
     * This method is called in [.onDestroy].
     */
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // No-op. Hook for subclasses.
    }

    /**
     * Hook for subclasses to control whether or not the [FlutterFragment] within this `Activity`
     * automatically attaches its [FlutterEngine] to this `Activity`.
     *
     *
     * This property is controlled with a protected method instead of an `Intent` argument
     * because the only situation where changing this value would help, is a situation in which
     * `ThrioFlutterActivity` is being subclassed to utilize a custom and/or cached [FlutterEngine].
     *
     *
     * Defaults to `true`.
     *
     *
     * Control surfaces are used to provide Android resources and lifecycle events to plugins that
     * are attached to the [FlutterEngine]. If `shouldAttachEngineToActivity` is true then
     * this `ThrioFlutterActivity` will connect its [FlutterEngine] to itself, along with any
     * plugins that are registered with that [FlutterEngine]. This allows plugins to access the
     * `Activity`, as well as receive `Activity`-specific calls, e.g., [ ][Activity.onNewIntent].
     * If `shouldAttachEngineToActivity` is false, then this
     * `ThrioFlutterActivity` will not automatically manage the connection between its [ ] and itself.
     * In this case, plugins will not be offered a reference to an `Activity` or its OS hooks.
     *
     *
     * Returning false from this method does not preclude a [FlutterEngine] from being
     * attaching to a `ThrioFlutterActivity` - it just prevents the attachment from happening
     * automatically. A developer can choose to subclass `ThrioFlutterActivity` and then invoke
     * [ActivityControlSurface.attachToActivity] and [ ][ActivityControlSurface.detachFromActivity]
     * at the desired times.
     *
     *
     * One reason that a developer might choose to manually manage the relationship between the
     * `Activity` and [FlutterEngine] is if the developer wants to move the [ ] somewhere else.
     * For example, a developer might want the [FlutterEngine] to outlive this `ThrioFlutterActivity`
     * so that it can be used later in a different `Activity`. To accomplish this, the [FlutterEngine]
     * may need to be disconnected from this `FluttterActivity` at an unusual time, preventing this
     * `ThrioFlutterActivity` from correctly managing the relationship between the [FlutterEngine] and itself.
     */
    override fun shouldAttachEngineToActivity(): Boolean {
        return true
    }

    override fun onFlutterSurfaceViewCreated(flutterSurfaceView: FlutterSurfaceView) {
        // Hook for subclasses.
    }

    override fun onFlutterTextureViewCreated(flutterTextureView: FlutterTextureView) {
        // Hook for subclasses.
    }

    override fun onFlutterUiDisplayed() {
        // Notifies Android that we're fully drawn so that performance metrics can be collected by
        // Flutter performance tests.
        // This was supported in KitKat (API 19), but has a bug around requiring
        // permissions. See https://github.com/flutter/flutter/issues/46172
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            reportFullyDrawn()
        }
    }

    override fun onFlutterUiNoLongerDisplayed() {
        // no-op
    }

    companion object {
        private const val TAG = "ThrioFlutterActivity"

        /**
         * Creates an [Intent] that launches a `ThrioFlutterActivity`, which creates a [ ] that
         * executes a `main()` Dart entrypoint, and displays the "/" route as Flutter's initial route.
         *
         *
         * Consider using the [.withCachedEngine] [Intent] builder to control when
         * the [FlutterEngine] should be created in your application.
         */
        fun createDefaultIntent(launchContext: Context): Intent {
            return withNewEngine().build(launchContext)
        }

        /**
         * Creates an [NewEngineIntentBuilder], which can be used to configure an [Intent] to
         * launch a `ThrioFlutterActivity` that internally creates a new [FlutterEngine] using the
         * desired Dart entrypoint, initial route, etc.
         */
        private fun withNewEngine(): NewEngineIntentBuilder {
            return NewEngineIntentBuilder(ThrioFlutterActivity::class.java)
        }

        /**
         * Creates a [CachedEngineIntentBuilder], which can be used to configure an [Intent]
         * to launch a `ThrioFlutterActivity` that internally uses an existing [FlutterEngine] that
         * is cached in [io.flutter.embedding.engine.FlutterEngineCache].
         */
        fun withCachedEngine(cachedEngineId: String): CachedEngineIntentBuilder {
            return CachedEngineIntentBuilder(ThrioFlutterActivity::class.java, cachedEngineId)
        }

        /**
         * Registers all plugins that an app lists in its pubspec.yaml.
         *
         *
         * The Flutter tool generates a class called GeneratedPluginRegistrant, which includes the code
         * necessary to register every plugin in the pubspec.yaml with a given `FlutterEngine`. The
         * GeneratedPluginRegistrant must be generated per app, because each app uses different sets of
         * plugins. Therefore, the Android embedding cannot place a compile-time dependency on this
         * generated class. This method uses reflection to attempt to locate the generated file and then
         * use it at runtime.
         *
         *
         * This method fizzles if the GeneratedPluginRegistrant cannot be found or invoked. This
         * situation should never occur, but if any eventuality comes up that prevents an app from using
         * this behavior, that app can still write code that explicitly registers plugins.
         */
        private fun registerPlugins(flutterEngine: FlutterEngine) {
            try {
                val generatedPluginRegistrant = Class.forName("io.flutter.plugins.GeneratedPluginRegistrant")
                val registrationMethod = generatedPluginRegistrant.getDeclaredMethod("registerWith", FlutterEngine::class.java)
                registrationMethod.invoke(null, flutterEngine)
            } catch (e: Exception) {
                Log.w(TAG,"Tried to automatically register plugins with FlutterEngine ("
                                + flutterEngine
                                + ") but could not find and invoke the GeneratedPluginRegistrant.")
            }
        }
    }
}
