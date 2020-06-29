package io.flutter.embedding.android

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.content.res.Configuration
import android.graphics.Insets
import android.graphics.Rect
import android.os.Build
import android.text.format.DateFormat
import android.util.AttributeSet
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.WindowInsets
import android.view.accessibility.AccessibilityManager
import android.view.accessibility.AccessibilityNodeProvider
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.widget.FrameLayout
import androidx.annotation.RequiresApi
import androidx.annotation.VisibleForTesting
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterRenderer
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.embedding.engine.renderer.RenderSurface
import io.flutter.embedding.engine.systemchannels.SettingsChannel
import io.flutter.plugin.editing.TextInputPlugin
import io.flutter.plugin.platform.PlatformViewsController
import io.flutter.view.AccessibilityBridge
import java.util.*


/**
 * Displays a Flutter UI on an Android device.
 *
 *
 * A `ThrioFlutterView`'s UI is painted by a corresponding [FlutterEngine].
 *
 *
 * A `ThrioFlutterView` can operate in 2 different [ ]s:
 *
 *
 *  1. [io.flutter.embedding.android.RenderMode.surface], which paints a Flutter UI to a
 * [android.view.SurfaceView]. This mode has the best performance, but a `ThrioFlutterView` in this mode cannot be positioned between 2 other Android `View`s in the
 * z-index, nor can it be animated/transformed. Unless the special capabilities of a [       ] are required, developers should strongly prefer this
 * render mode.
 *  1. [io.flutter.embedding.android.RenderMode.texture], which paints a Flutter UI to a
 * [android.graphics.SurfaceTexture]. This mode is not as performant as [       ][io.flutter.embedding.android.RenderMode.surface], but a `ThrioFlutterView` in this mode
 * can be animated and transformed, as well as positioned in the z-index between 2+ other
 * Android `Views`. Unless the special capabilities of a [       ] are required, developers should strongly prefer the [       ][io.flutter.embedding.android.RenderMode.surface] render mode.
 *
 *
 * See <a>https://source.android.com/devices/graphics/arch-tv#surface_or_texture</a> for more
 * information comparing [android.view.SurfaceView] and [android.view.TextureView].
 */
class ThrioFlutterView : FrameLayout {
    // Internal view hierarchy references.
    private var flutterSurfaceView: FlutterSurfaceView? = null
    private var flutterTextureView: FlutterTextureView? = null
    private var renderSurface: RenderSurface? = null
    private val flutterUiDisplayListeners: MutableSet<FlutterUiDisplayListener> = HashSet()
    private var isFlutterUiDisplayed = false

    /**
     * Returns the [FlutterEngine] to which this `ThrioFlutterView` is currently attached, or
     * null if this `ThrioFlutterView` is not currently attached to a [FlutterEngine].
     */
    // Connections to a Flutter execution context.
    @get:VisibleForTesting
    var attachedFlutterEngine: FlutterEngine? = null
        private set
    private val flutterEngineAttachmentListeners: MutableSet<FlutterEngineAttachmentListener> = HashSet()

    // Components that process various types of Android View input and events,
    // possibly storing intermediate state, and communicating those events to Flutter.
    //
    // These components essentially add some additional behavioral logic on top of
    // existing, stateless system channels, e.g., KeyEventChannel, TextInputChannel, etc.
    private var textInputPlugin: TextInputPlugin? = null
    private var androidKeyProcessor: AndroidKeyProcessor? = null
    private var androidTouchProcessor: AndroidTouchProcessor? = null
    private var accessibilityBridge: AccessibilityBridge? = null

    // Directly implemented View behavior that communicates with Flutter.
    private val viewportMetrics = FlutterRenderer.ViewportMetrics()
    private val onAccessibilityChangeListener = AccessibilityBridge.OnAccessibilityChangeListener { isAccessibilityEnabled,
                                                                                                    isTouchExplorationEnabled ->
        resetWillNotDraw(
                isAccessibilityEnabled,
                isTouchExplorationEnabled)
    }
    private val flutterUiDisplayListener: FlutterUiDisplayListener = object : FlutterUiDisplayListener {
        override fun onFlutterUiDisplayed() {
            isFlutterUiDisplayed = true
            for (listener in flutterUiDisplayListeners) {
                listener.onFlutterUiDisplayed()
            }
        }

        override fun onFlutterUiNoLongerDisplayed() {
            isFlutterUiDisplayed = false
            for (listener in flutterUiDisplayListeners) {
                listener.onFlutterUiNoLongerDisplayed()
            }
        }
    }

    /**
     * Constructs a `ThrioFlutterView` programmatically, without any XML attributes.
     *
     *
     *
     *
     *
     *  * A [FlutterSurfaceView] is used to render the Flutter UI.
     *  * `transparencyMode` defaults to [TransparencyMode.opaque].
     *
     *
     * `ThrioFlutterView` requires an `Activity` instead of a generic `Context` to be
     * compatible with [PlatformViewsController].
     */
    constructor(context: Context) : this(context, null, FlutterSurfaceView(context)) {}

    /**
     * Deprecated - use [.FlutterView] or [ ][.FlutterView] instead.
     */
    @Deprecated("")
    constructor(context: Context, renderMode: RenderMode) : super(context, null) {
        if (renderMode == RenderMode.surface) {
            flutterSurfaceView = FlutterSurfaceView(context)
            renderSurface = flutterSurfaceView
        } else {
            flutterTextureView = FlutterTextureView(context)
            renderSurface = flutterTextureView
        }
        init()
    }

    /**
     * Deprecated - use [.FlutterView] or [ ][.FlutterView] instead, and configure the incoming `FlutterSurfaceView` or `FlutterTextureView` for transparency as desired.
     *
     *
     * Constructs a `ThrioFlutterView` programmatically, without any XML attributes, uses a [ ] to render the Flutter UI, and allows selection of a `transparencyMode`.
     *
     *
     * `ThrioFlutterView` requires an `Activity` instead of a generic `Context` to be
     * compatible with [PlatformViewsController].
     */
    @Deprecated("")
    constructor(context: Context, transparencyMode: TransparencyMode) : this(
            context,
            null,
            FlutterSurfaceView(context, transparencyMode == TransparencyMode.transparent)) {
    }

    /**
     * Constructs a `ThrioFlutterView` programmatically, without any XML attributes, uses the given
     * [FlutterSurfaceView] to render the Flutter UI, and allows selection of a `transparencyMode`.
     *
     *
     * `ThrioFlutterView` requires an `Activity` instead of a generic `Context` to be
     * compatible with [PlatformViewsController].
     */
    constructor(context: Context, flutterSurfaceView: FlutterSurfaceView) : this(context, null, flutterSurfaceView) {}

    /**
     * Constructs a `ThrioFlutterView` programmatically, without any XML attributes, uses the given
     * [FlutterTextureView] to render the Flutter UI, and allows selection of a `transparencyMode`.
     *
     *
     * `ThrioFlutterView` requires an `Activity` instead of a generic `Context` to be
     * compatible with [PlatformViewsController].
     */
    constructor(context: Context, flutterTextureView: FlutterTextureView) : this(context, null, flutterTextureView) {}

    /**
     * Constructs a `ThrioFlutterView` in an XML-inflation-compliant manner.
     *
     *
     * `ThrioFlutterView` requires an `Activity` instead of a generic `Context` to be
     * compatible with [PlatformViewsController].
     */
    // TODO(mattcarroll): expose renderMode in XML when build system supports R.attr
    constructor(context: Context, attrs: AttributeSet?) : this(context, attrs, FlutterSurfaceView(context)) {}

    /**
     * Deprecated - use [.FlutterView] or [ ][.FlutterView] instead, and configure the incoming `FlutterSurfaceView` or `FlutterTextureView` for transparency as desired.
     */
    @Deprecated("")
    constructor(
            context: Context,
            renderMode: RenderMode,
            transparencyMode: TransparencyMode) : super(context, null) {
        if (renderMode == RenderMode.surface) {
            flutterSurfaceView = FlutterSurfaceView(context, transparencyMode == TransparencyMode.transparent)
            renderSurface = flutterSurfaceView
        } else {
            flutterTextureView = FlutterTextureView(context)
            renderSurface = flutterTextureView
        }
        init()
    }

    private constructor(
            context: Context,
            attrs: AttributeSet?,
            flutterSurfaceView: FlutterSurfaceView) : super(context, attrs) {
        this.flutterSurfaceView = flutterSurfaceView
        renderSurface = flutterSurfaceView
        init()
    }

    private constructor(
            context: Context,
            attrs: AttributeSet?,
            flutterTextureView: FlutterTextureView) : super(context, attrs) {
        this.flutterTextureView = flutterTextureView
        renderSurface = flutterSurfaceView
        init()
    }

    private fun init() {
        Log.v(TAG, "Initializing FlutterView")
        if (flutterSurfaceView != null) {
            Log.v(TAG, "Internally using a FlutterSurfaceView.")
            addView(flutterSurfaceView)
        } else {
            Log.v(TAG, "Internally using a FlutterTextureView.")
            addView(flutterTextureView)
        }

        // FlutterView needs to be focusable so that the InputMethodManager can interact with it.
        isFocusable = true
        isFocusableInTouchMode = true
    }

    /**
     * Returns true if an attached [FlutterEngine] has rendered at least 1 frame to this `ThrioFlutterView`.
     *
     *
     * Returns false if no [FlutterEngine] is attached.
     *
     *
     * This flag is specific to a given [FlutterEngine]. The following hypothetical timeline
     * demonstrates how this flag changes over time.
     *
     *
     *  1. `flutterEngineA` is attached to this `ThrioFlutterView`: returns false
     *  1. `flutterEngineA` renders its first frame to this `ThrioFlutterView`: returns true
     *  1. `flutterEngineA` is detached from this `ThrioFlutterView`: returns false
     *  1. `flutterEngineB` is attached to this `ThrioFlutterView`: returns false
     *  1. `flutterEngineB` renders its first frame to this `ThrioFlutterView`: returns true
     *
     */
    fun hasRenderedFirstFrame(): Boolean {
        return isFlutterUiDisplayed
    }

    /**
     * Adds the given `listener` to this `ThrioFlutterView`, to be notified upon Flutter's
     * first rendered frame.
     */
    fun addOnFirstFrameRenderedListener(listener: FlutterUiDisplayListener) {
        flutterUiDisplayListeners.add(listener)
    }

    /**
     * Removes the given `listener`, which was previously added with [ ][.addOnFirstFrameRenderedListener].
     */
    fun removeOnFirstFrameRenderedListener(listener: FlutterUiDisplayListener) {
        flutterUiDisplayListeners.remove(listener)
    }

    /**
     * Sends relevant configuration data from Android to Flutter when the Android [ ] changes.
     *
     *
     * The Android [Configuration] might change as a result of device orientation change,
     * device language change, device text scale factor change, etc.
     */
    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        // We've observed on Android Q that going to the background, changing
        // orientation, and bringing the app back to foreground results in a sequence
        // of detatch from flutterEngine, onConfigurationChanged, followed by attach
        // to flutterEngine.
        // No-op here so that we avoid NPE; these channels will get notified once
        // the activity or fragment tell the view to attach to the Flutter engine
        // again (e.g. in onStart).
        if (attachedFlutterEngine != null) {
            Log.v(TAG, "Configuration changed. Sending locales and user settings to Flutter.")
            sendLocalesToFlutter(newConfig)
            sendUserSettingsToFlutter()
        }
    }

    /**
     * Invoked when this `ThrioFlutterView` changes size, including upon initial measure.
     *
     *
     * The initial measure reports an `oldWidth` and `oldHeight` of zero.
     *
     *
     * Flutter cares about the width and height of the view that displays it on the host platform.
     * Therefore, when this method is invoked, the new width and height are communicated to Flutter as
     * the "physical size" of the view that displays Flutter's UI.
     */
    override fun onSizeChanged(width: Int, height: Int, oldWidth: Int, oldHeight: Int) {
        super.onSizeChanged(width, height, oldWidth, oldHeight)
        Log.v(
                TAG,
                "Size changed. Sending Flutter new viewport metrics. FlutterView was "
                        + oldWidth
                        + " x "
                        + oldHeight
                        + ", it is now "
                        + width
                        + " x "
                        + height)
        viewportMetrics.width = width
        viewportMetrics.height = height
        sendViewportMetricsToFlutter()
    }

    /**
     * Invoked when Android's desired window insets change, i.e., padding.
     *
     *
     * Flutter does not use a standard `View` hierarchy and therefore Flutter is unaware of
     * these insets. Therefore, this method calculates the viewport metrics that Flutter should use
     * and then sends those metrics to Flutter.
     *
     *
     * This callback is not present in API < 20, which means lower API devices will see the wider
     * than expected padding when the status and navigation bars are hidden.
     */
    @TargetApi(20)
    @RequiresApi(20) // The annotations to suppress "InlinedApi" and "NewApi" lints prevent lint warnings
    // caused by usage of Android Q APIs. These calls are safe because they are
    // guarded.
    @SuppressLint("InlinedApi", "NewApi")
    override fun onApplyWindowInsets(insets: WindowInsets): WindowInsets {
        val newInsets = super.onApplyWindowInsets(insets)

        // Status bar (top) and left/right system insets should partially obscure the content (padding).
        viewportMetrics.paddingTop = insets.systemWindowInsetTop
        viewportMetrics.paddingRight = insets.systemWindowInsetRight
        viewportMetrics.paddingBottom = 0
        viewportMetrics.paddingLeft = insets.systemWindowInsetLeft

        // Bottom system inset (keyboard) should adjust scrollable bottom edge (inset).
        viewportMetrics.viewInsetTop = 0
        viewportMetrics.viewInsetRight = 0
        viewportMetrics.viewInsetBottom = insets.systemWindowInsetBottom
        viewportMetrics.viewInsetLeft = 0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val systemGestureInsets: Insets = insets.getSystemGestureInsets()
            viewportMetrics.systemGestureInsetTop = systemGestureInsets.top
            viewportMetrics.systemGestureInsetRight = systemGestureInsets.right
            viewportMetrics.systemGestureInsetBottom = systemGestureInsets.bottom
            viewportMetrics.systemGestureInsetLeft = systemGestureInsets.left
        }
        Log.v(
                TAG,
                """
                    Updating window insets (onApplyWindowInsets()):
                    Status bar insets: Top: ${viewportMetrics.paddingTop}, Left: ${viewportMetrics.paddingLeft}, Right: ${viewportMetrics.paddingRight}
                    Keyboard insets: Bottom: ${viewportMetrics.viewInsetBottom}, Left: ${viewportMetrics.viewInsetLeft}, Right: ${viewportMetrics.viewInsetRight}System Gesture Insets - Left: ${viewportMetrics.systemGestureInsetLeft}, Top: ${viewportMetrics.systemGestureInsetTop}, Right: ${viewportMetrics.systemGestureInsetRight}, Bottom: ${viewportMetrics.viewInsetBottom}
                    """.trimIndent())
        sendViewportMetricsToFlutter()
        return newInsets
    }

    /**
     * Invoked when Android's desired window insets change, i.e., padding.
     *
     *
     * `fitSystemWindows` is an earlier version of [ ][.onApplyWindowInsets]. See that method for more details about how window insets
     * relate to Flutter.
     */
    override fun fitSystemWindows(insets: Rect): Boolean {
        return if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
            // Status bar, left/right system insets partially obscure content (padding).
            viewportMetrics.paddingTop = insets.top
            viewportMetrics.paddingRight = insets.right
            viewportMetrics.paddingBottom = 0
            viewportMetrics.paddingLeft = insets.left

            // Bottom system inset (keyboard) should adjust scrollable bottom edge (inset).
            viewportMetrics.viewInsetTop = 0
            viewportMetrics.viewInsetRight = 0
            viewportMetrics.viewInsetBottom = insets.bottom
            viewportMetrics.viewInsetLeft = 0
            Log.v(
                    TAG,
                    """
                        Updating window insets (fitSystemWindows()):
                        Status bar insets: Top: ${viewportMetrics.paddingTop}, Left: ${viewportMetrics.paddingLeft}, Right: ${viewportMetrics.paddingRight}
                        Keyboard insets: Bottom: ${viewportMetrics.viewInsetBottom}, Left: ${viewportMetrics.viewInsetLeft}, Right: ${viewportMetrics.viewInsetRight}
                        """.trimIndent())
            sendViewportMetricsToFlutter()
            true
        } else {
            super.fitSystemWindows(insets)
        }
    }

    /**
     * Creates an [InputConnection] to work with a [ ].
     *
     *
     * Any `View` that can take focus or process text input must implement this method by
     * returning a non-null `InputConnection`. Flutter may render one or many focusable and
     * text-input widgets, therefore `ThrioFlutterView` must support an `InputConnection`.
     *
     *
     * The `InputConnection` returned from this method comes from a [TextInputPlugin],
     * which is owned by this `ThrioFlutterView`. A [TextInputPlugin] exists to encapsulate the
     * nuances of input communication, rather than spread that logic throughout this `ThrioFlutterView`.
     */
    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection? {
        return if (!isAttachedToFlutterEngine) {
            super.onCreateInputConnection(outAttrs)
        } else textInputPlugin!!.createInputConnection(this, outAttrs)
    }

    /**
     * Allows a `View` that is not currently the input connection target to invoke commands on
     * the [android.view.inputmethod.InputMethodManager], which is otherwise disallowed.
     *
     *
     * Returns true to allow non-input-connection-targets to invoke methods on `InputMethodManager`, or false to exclusively allow the input connection target to invoke such
     * methods.
     */
    override fun checkInputConnectionProxy(view: View): Boolean {
        return if (attachedFlutterEngine != null) attachedFlutterEngine!!.platformViewsController.checkInputConnectionProxy(view) else super.checkInputConnectionProxy(view)
    }

    /**
     * Invoked when key is released.
     *
     *
     * This method is typically invoked in response to the release of a physical keyboard key or a
     * D-pad button. It is generally not invoked when a virtual software keyboard is used, though a
     * software keyboard may choose to invoke this method in some situations.
     *
     *
     * [KeyEvent]s are sent from Android to Flutter. [AndroidKeyProcessor] may do some
     * additional work with the given [KeyEvent], e.g., combine this `keyCode` with the
     * previous `keyCode` to generate a unicode combined character.
     */
    override fun onKeyUp(keyCode: Int, event: KeyEvent): Boolean {
        if (!isAttachedToFlutterEngine) {
            return super.onKeyUp(keyCode, event)
        }
        androidKeyProcessor!!.onKeyUp(event)
        return super.onKeyUp(keyCode, event)
    }

    /**
     * Invoked when key is pressed.
     *
     *
     * This method is typically invoked in response to the press of a physical keyboard key or a
     * D-pad button. It is generally not invoked when a virtual software keyboard is used, though a
     * software keyboard may choose to invoke this method in some situations.
     *
     *
     * [KeyEvent]s are sent from Android to Flutter. [AndroidKeyProcessor] may do some
     * additional work with the given [KeyEvent], e.g., combine this `keyCode` with the
     * previous `keyCode` to generate a unicode combined character.
     */
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (!isAttachedToFlutterEngine) {
            return super.onKeyDown(keyCode, event)
        }
        androidKeyProcessor!!.onKeyDown(event)
        return super.onKeyDown(keyCode, event)
    }

    /**
     * Invoked by Android when a user touch event occurs.
     *
     *
     * Flutter handles all of its own gesture detection and processing, therefore this method
     * forwards all [MotionEvent] data from Android to Flutter.
     */
    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (!isAttachedToFlutterEngine) {
            return super.onTouchEvent(event)
        }

        // TODO(abarth): This version check might not be effective in some
        // versions of Android that statically compile code and will be upset
        // at the lack of |requestUnbufferedDispatch|. Instead, we should factor
        // version-dependent code into separate classes for each supported
        // version and dispatch dynamically.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            requestUnbufferedDispatch(event)
        }
        return androidTouchProcessor!!.onTouchEvent(event)
    }

    /**
     * Invoked by Android when a generic motion event occurs, e.g., joystick movement, mouse hover,
     * track pad touches, scroll wheel movements, etc.
     *
     *
     * Flutter handles all of its own gesture detection and processing, therefore this method
     * forwards all [MotionEvent] data from Android to Flutter.
     */
    override fun onGenericMotionEvent(event: MotionEvent): Boolean {
        val handled = isAttachedToFlutterEngine && androidTouchProcessor!!.onGenericMotionEvent(event)
        return if (handled) true else super.onGenericMotionEvent(event)
    }

    /**
     * Invoked by Android when a hover-compliant input system causes a hover event.
     *
     *
     * An example of hover events is a stylus sitting near an Android screen. As the stylus moves
     * from outside a `View` to hover over a `View`, or move around within a `View`,
     * or moves from over a `View` to outside a `View`, a corresponding [ ] is reported via this method.
     *
     *
     * Hover events can be used for accessibility touch exploration and therefore are processed
     * here for accessibility purposes.
     */
    override fun onHoverEvent(event: MotionEvent): Boolean {
        if (!isAttachedToFlutterEngine) {
            return super.onHoverEvent(event)
        }
        val handled = accessibilityBridge!!.onAccessibilityHoverEvent(event)
        if (!handled) {
            // TODO(ianh): Expose hover events to the platform,
            // implementing ADD, REMOVE, etc.
        }
        return handled
    }

    override fun getAccessibilityNodeProvider(): AccessibilityNodeProvider? {
        return if (accessibilityBridge != null && accessibilityBridge!!.isAccessibilityEnabled) {
            accessibilityBridge
        } else {
            // TODO(goderbauer): when a11y is off this should return a one-off snapshot of
            // the a11y
            // tree.
            null
        }
    }

    // TODO(mattcarroll): Confer with Ian as to why we need this method. Delete if possible, otherwise
    // add comments.
    private fun resetWillNotDraw(isAccessibilityEnabled: Boolean, isTouchExplorationEnabled: Boolean) {
        if (!attachedFlutterEngine!!.renderer.isSoftwareRenderingEnabled) {
            setWillNotDraw(!(isAccessibilityEnabled || isTouchExplorationEnabled))
        } else {
            setWillNotDraw(false)
        }
    }

    /**
     * Connects this `ThrioFlutterView` to the given [FlutterEngine].
     *
     *
     * This `ThrioFlutterView` will begin rendering the UI painted by the given [ ]. This `ThrioFlutterView` will also begin forwarding interaction events from
     * this `ThrioFlutterView` to the given [FlutterEngine], e.g., user touch events,
     * accessibility events, keyboard events, and others.
     *
     *
     * See [.detachFromFlutterEngine] for information on how to detach from a [ ].
     */
    fun attachToFlutterEngine(flutterEngine: FlutterEngine) {
        Log.v(TAG, "Attaching to a FlutterEngine: $flutterEngine")
        if (isAttachedToFlutterEngine) {
            if (flutterEngine === attachedFlutterEngine) {
                // We are already attached to this FlutterEngine
                Log.v(TAG, "Already attached to this engine. Doing nothing.")
                return
            }

            // Detach from a previous FlutterEngine so we can attach to this new one.
            Log.v(
                    TAG, "Currently attached to a different engine. Detaching and then attaching"
                    + " to new engine.")
            detachFromFlutterEngine()
        }
        attachedFlutterEngine = flutterEngine

        // Instruct our FlutterRenderer that we are now its designated RenderSurface.
        val flutterRenderer = attachedFlutterEngine!!.renderer
        isFlutterUiDisplayed = flutterRenderer.isDisplayingFlutterUi
        renderSurface!!.attachToRenderer(flutterRenderer)
        flutterRenderer.addIsDisplayingFlutterUiListener(flutterUiDisplayListener)

        // Initialize various components that know how to process Android View I/O
        // in a way that Flutter understands.
        textInputPlugin = TextInputPlugin(
                this,
                attachedFlutterEngine!!.dartExecutor,
                attachedFlutterEngine!!.platformViewsController)
        androidKeyProcessor = AndroidKeyProcessor(attachedFlutterEngine!!.keyEventChannel, textInputPlugin!!)
        androidTouchProcessor = AndroidTouchProcessor(attachedFlutterEngine!!.renderer)
        accessibilityBridge = AccessibilityBridge(
                this,
                flutterEngine.accessibilityChannel,
                (context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager),
                context.contentResolver,
                attachedFlutterEngine!!.platformViewsController)
        accessibilityBridge!!.setOnAccessibilityChangeListener(onAccessibilityChangeListener)
        resetWillNotDraw(
                accessibilityBridge!!.isAccessibilityEnabled,
                accessibilityBridge!!.isTouchExplorationEnabled)

        // Connect AccessibilityBridge to the PlatformViewsController within the FlutterEngine.
        // This allows platform Views to hook into Flutter's overall accessibility system.
        attachedFlutterEngine!!.platformViewsController.attachAccessibilityBridge(accessibilityBridge)

        // Inform the Android framework that it should retrieve a new InputConnection
        // now that an engine is attached.
        // TODO(mattcarroll): once this is proven to work, move this line ot TextInputPlugin
        textInputPlugin!!.inputMethodManager.restartInput(this)

        // Push View and Context related information from Android to Flutter.
        sendUserSettingsToFlutter()
        sendLocalesToFlutter(resources.configuration)
        sendViewportMetricsToFlutter()
        flutterEngine.platformViewsController.attachToView(this)

        // Notify engine attachment listeners of the attachment.
        for (listener in flutterEngineAttachmentListeners) {
            listener.onFlutterEngineAttachedToFlutterView(flutterEngine)
        }

        // If the first frame has already been rendered, notify all first frame listeners.
        // Do this after all other initialization so that listeners don't inadvertently interact
        // with a FlutterView that is only partially attached to a FlutterEngine.
        if (isFlutterUiDisplayed) {
            flutterUiDisplayListener.onFlutterUiDisplayed()
        }
    }

    /**
     * Reconnects this `ThrioFlutterView` to the given [attachedFlutterEngine].
     *
     *
     * This `ThrioFlutterView` will begin rendering the UI painted by the given [ ]. This
     * `ThrioFlutterView` will also begin forwarding interaction events from
     * this `ThrioFlutterView` to the given [attachedFlutterEngine], e.g., user touch events,
     * accessibility events, keyboard events, and others.
     *
     *
     * See [.detachFromFlutterEngine] for information on how to detach from a [ ].
     */
    fun reattachToFlutterEngine() {
        attachedFlutterEngine?.let { engine ->
            // Instruct our FlutterRenderer that we are now its designated RenderSurface.
            isFlutterUiDisplayed = engine.renderer.isDisplayingFlutterUi

            renderSurface!!.attachToRenderer(engine.renderer)
            engine.renderer.addIsDisplayingFlutterUiListener(flutterUiDisplayListener)

            // Initialize various components that know how to process Android View I/O
            // in a way that Flutter understands.
            textInputPlugin = TextInputPlugin(this, engine.dartExecutor, engine.platformViewsController)
            androidKeyProcessor = AndroidKeyProcessor(engine.keyEventChannel, textInputPlugin!!)
            androidTouchProcessor = AndroidTouchProcessor(engine.renderer)
            accessibilityBridge = AccessibilityBridge(
                    this,
                    engine.accessibilityChannel,
                    (context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager),
                    context.contentResolver,
                    engine.platformViewsController)
            accessibilityBridge!!.setOnAccessibilityChangeListener(onAccessibilityChangeListener)
            resetWillNotDraw(
                    accessibilityBridge!!.isAccessibilityEnabled,
                    accessibilityBridge!!.isTouchExplorationEnabled)

            // Connect AccessibilityBridge to the PlatformViewsController within the FlutterEngine.
            // This allows platform Views to hook into Flutter's overall accessibility system.
            engine.platformViewsController.attachAccessibilityBridge(accessibilityBridge)

            // Inform the Android framework that it should retrieve a new InputConnection
            // now that an engine is attached.
            // TODO(mattcarroll): once this is proven to work, move this line ot TextInputPlugin
            textInputPlugin!!.inputMethodManager.restartInput(this)

            // Push View and Context related information from Android to Flutter.
            engine.platformViewsController.attachToView(this)

            // Notify engine attachment listeners of the attachment.
            for (listener in flutterEngineAttachmentListeners) {
                listener.onFlutterEngineAttachedToFlutterView(engine)
            }

            // If the first frame has already been rendered, notify all first frame listeners.
            // Do this after all other initialization so that listeners don't inadvertently interact
            // with a FlutterView that is only partially attached to a FlutterEngine.
            if (isFlutterUiDisplayed) {
                flutterUiDisplayListener.onFlutterUiDisplayed()
            }
        }
    }

    /**
     * Disconnects this `ThrioFlutterView` from a previously attached [FlutterEngine].
     *
     *
     * This `ThrioFlutterView` will clear its UI and stop forwarding all events to the
     * previously-attached [FlutterEngine]. This includes touch events, accessibility events,
     * keyboard events, and others.
     *
     *
     * See [.attachToFlutterEngine] for information on how to attach a [ ].
     */
    fun detachFromFlutterEngine() {
        Log.v(TAG, "Detaching from a FlutterEngine: $attachedFlutterEngine")
        if (!isAttachedToFlutterEngine) {
            Log.v(TAG, "Not attached to an engine. Doing nothing.")
            return
        }

        // Notify engine attachment listeners of the detachment.
        for (listener in flutterEngineAttachmentListeners) {
            listener.onFlutterEngineDetachedFromFlutterView()
        }
        attachedFlutterEngine?.let { engine ->
            engine.platformViewsController.detachFromView()

            // Disconnect the FlutterEngine's PlatformViewsController from the AccessibilityBridge.
            engine.platformViewsController.detachAccessibiltyBridge()


        }
        // Disconnect and clean up the AccessibilityBridge.
        accessibilityBridge?.release()
        accessibilityBridge = null

        // Inform the Android framework that it should retrieve a new InputConnection
        // now that the engine is detached. The new InputConnection will be null, which
        // signifies that this View does not process input (until a new engine is attached).
        // TODO(mattcarroll): once this is proven to work, move this line ot TextInputPlugin
        textInputPlugin?.inputMethodManager?.restartInput(this)
        textInputPlugin?.destroy()

        // Instruct our FlutterRenderer that we are no longer interested in being its RenderSurface.
        isFlutterUiDisplayed = false
        attachedFlutterEngine?.renderer?.let {
            it.removeIsDisplayingFlutterUiListener(flutterUiDisplayListener)
            it.stopRenderingToSurface()
            it.setSemanticsEnabled(false)
        }
        renderSurface?.detachFromRenderer()
        attachedFlutterEngine = null
    }

    /** Returns true if this `ThrioFlutterView` is currently attached to a [FlutterEngine].  */
    @get:VisibleForTesting
    val isAttachedToFlutterEngine: Boolean
        get() = (attachedFlutterEngine != null
                && attachedFlutterEngine!!.renderer === renderSurface!!.attachedRenderer)

    /**
     * Adds a [FlutterEngineAttachmentListener], which is notifed whenever this `ThrioFlutterView` attached to/detaches from a [FlutterEngine].
     */
    @VisibleForTesting
    fun addFlutterEngineAttachmentListener(
            listener: FlutterEngineAttachmentListener) {
        flutterEngineAttachmentListeners.add(listener)
    }

    /**
     * Removes a [FlutterEngineAttachmentListener] that was previously added with [ ][.addFlutterEngineAttachmentListener].
     */
    @VisibleForTesting
    fun removeFlutterEngineAttachmentListener(
            listener: FlutterEngineAttachmentListener) {
        flutterEngineAttachmentListeners.remove(listener)
    }

    /**
     * Send the current [Locale] configuration to Flutter.
     *
     *
     * FlutterEngine must be non-null when this method is invoked.
     */
    private fun sendLocalesToFlutter(config: Configuration) {
        val locales: MutableList<Locale> = ArrayList()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            val localeList = config.locales
            val localeCount = localeList.size()
            for (index in 0 until localeCount) {
                val locale = localeList[index]
                locales.add(locale)
            }
        } else {
            locales.add(config.locale)
        }
        attachedFlutterEngine!!.localizationChannel.sendLocales(locales)
    }

    /**
     * Send various user preferences of this Android device to Flutter.
     *
     *
     * For example, sends the user's "text scale factor" preferences, as well as the user's clock
     * format preference.
     *
     *
     * FlutterEngine must be non-null when this method is invoked.
     */
    @VisibleForTesting
    fun  /* package */sendUserSettingsToFlutter() {
        // Lookup the current brightness of the Android OS.
        val isNightModeOn = (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                == Configuration.UI_MODE_NIGHT_YES)
        val brightness = if (isNightModeOn) SettingsChannel.PlatformBrightness.dark else SettingsChannel.PlatformBrightness.light
        attachedFlutterEngine?.let {
            it.settingsChannel
                    .startMessage()
                    .setTextScaleFactor(resources.configuration.fontScale)
                    .setUse24HourFormat(DateFormat.is24HourFormat(context))
                    .setPlatformBrightness(brightness)
                    .send()
        }
    }

    // TODO(mattcarroll): consider introducing a system channel for this communication instead of JNI
    private fun sendViewportMetricsToFlutter() {
        if (!isAttachedToFlutterEngine) {
            Log.w(
                    TAG, "Tried to send viewport metrics from Android to Flutter but this "
                    + "FlutterView was not attached to a FlutterEngine.")
            return
        }
        viewportMetrics.devicePixelRatio = resources.displayMetrics.density
        attachedFlutterEngine!!.renderer.setViewportMetrics(viewportMetrics)
    }
//
//    /**
//     * Render modes for a [FlutterView].
//     *
//     *
//     * Deprecated - please use [io.flutter.embedding.android.RenderMode] instead.
//     */
//    @Deprecated("")
//    enum class RenderMode {
//        /**
//         * `RenderMode`, which paints a Flutter UI to a [android.view.SurfaceView]. This
//         * mode has the best performance, but a `ThrioFlutterView` in this mode cannot be positioned
//         * between 2 other Android `View`s in the z-index, nor can it be animated/transformed.
//         * Unless the special capabilities of a [android.graphics.SurfaceTexture] are required,
//         * developers should strongly prefer this render mode.
//         */
//        surface,
//
//        /**
//         * `RenderMode`, which paints a Flutter UI to a [android.graphics.SurfaceTexture].
//         * This mode is not as performant as [RenderMode.surface], but a `ThrioFlutterView` in
//         * this mode can be animated and transformed, as well as positioned in the z-index between 2+
//         * other Android `Views`. Unless the special capabilities of a [ ] are required, developers should strongly prefer the [ ][RenderMode.surface] render mode.
//         */
//        texture
//    }

    /**
     * Transparency mode for a `ThrioFlutterView`.
     *
     *
     * Deprecated - please use [io.flutter.embedding.android.TransparencyMode] instead.
     *
     *
     * `TransparencyMode` impacts the visual behavior and performance of a [ ], which is displayed when a `ThrioFlutterView` uses [ ][RenderMode.surface].
     *
     *
     * `TransparencyMode` does not impact [FlutterTextureView], which is displayed when
     * a `ThrioFlutterView` uses [RenderMode.texture], because a [FlutterTextureView]
     * automatically comes with transparency.
     */
//    @Deprecated("")
//    enum class TransparencyMode {
//        /**
//         * Renders a `ThrioFlutterView` without any transparency. This affects `ThrioFlutterView`s in
//         * [io.flutter.embedding.android.RenderMode.surface] by introducing a base color of black,
//         * and places the [FlutterSurfaceView]'s `Window` behind all other content.
//         *
//         *
//         * In [io.flutter.embedding.android.RenderMode.surface], this mode is the most
//         * performant and is a good choice for fullscreen Flutter UIs that will not undergo `Fragment` transactions. If this mode is used within a `Fragment`, and that `Fragment` is replaced by another one, a brief black flicker may be visible during the switch.
//         */
//        opaque,
//
//        /**
//         * Renders a `ThrioFlutterView` with transparency. This affects `ThrioFlutterView`s in [ ][io.flutter.embedding.android.RenderMode.surface] by allowing background transparency, and
//         * places the [FlutterSurfaceView]'s `Window` on top of all other content.
//         *
//         *
//         * In [io.flutter.embedding.android.RenderMode.surface], this mode is less performant
//         * than [.opaque], but this mode avoids the black flicker problem that [.opaque] has
//         * when going through `Fragment` transactions. Consider using this `TransparencyMode` if you intend to switch `Fragment`s at runtime that contain a Flutter
//         * UI.
//         */
//        transparent
//    }

    /**
     * Listener that is notified when a [FlutterEngine] is attached to/detached from a given
     * `ThrioFlutterView`.
     */
    @VisibleForTesting
    interface FlutterEngineAttachmentListener {
        /** The given `engine` has been attached to the associated `ThrioFlutterView`.  */
        fun onFlutterEngineAttachedToFlutterView(engine: FlutterEngine)

        /**
         * A previously attached [FlutterEngine] has been detached from the associated `ThrioFlutterView`.
         */
        fun onFlutterEngineDetachedFromFlutterView()
    }

    companion object {
        private const val TAG = "FlutterView"
    }
}
