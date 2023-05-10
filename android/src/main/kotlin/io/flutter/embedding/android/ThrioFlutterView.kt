package io.flutter.embedding.android

import android.content.Context
import android.database.ContentObserver
import android.os.Build
import android.provider.Settings
import android.view.accessibility.AccessibilityManager
import android.view.textservice.TextServicesManager
import com.foxsofter.flutter_thrio.extension.*
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener
import io.flutter.plugin.editing.SpellCheckPlugin
import io.flutter.plugin.editing.TextInputPlugin
import io.flutter.plugin.localization.LocalizationPlugin
import io.flutter.plugin.mouse.MouseCursorPlugin
import io.flutter.view.AccessibilityBridge

class ThrioFlutterView(context: Context, renderMode: RenderMode) :
    FlutterView(context, renderMode) {
    companion object {
        const val TAG = "ThrioFlutterView"
    }

    private var flutterEngine
        get() = getSuperFieldNullableValue<FlutterEngine>("flutterEngine")
        set(value) = setSuperFieldValue("flutterEngine", value)

    private var isFlutterUiDisplayed
        get() = getSuperFieldBoolean("isFlutterUiDisplayed")
        set(value) = setSuperFieldBoolean("isFlutterUiDisplayed", value)

    private val flutterUiDisplayListener
        get() = getSuperFieldValue<FlutterUiDisplayListener>("flutterUiDisplayListener")

    private var mouseCursorPlugin
        get() = getSuperFieldNullableValue<MouseCursorPlugin>("mouseCursorPlugin")
        set(value) = setSuperFieldValue("mouseCursorPlugin", value)

    private var textInputPlugin
        get() = getSuperFieldNullableValue<TextInputPlugin>("textInputPlugin")
        set(value) = setSuperFieldValue("textInputPlugin", value)

    private var textServicesManager
        get() = getSuperFieldNullableValue<TextServicesManager>("textServicesManager")
        set(value) = setSuperFieldValue("textServicesManager", value)

    private var spellCheckPlugin
        get() = getSuperFieldNullableValue<SpellCheckPlugin>("spellCheckPlugin")
        set(value) = setSuperFieldValue("spellCheckPlugin", value)

    private var localizationPlugin
        get() = getSuperFieldNullableValue<LocalizationPlugin>("localizationPlugin")
        set(value) = setSuperFieldValue("localizationPlugin", value)

    private var keyboardManager
        get() = getSuperFieldNullableValue<KeyboardManager>("keyboardManager")
        set(value) = setSuperFieldValue("keyboardManager", value)

    private var androidTouchProcessor
        get() = getSuperFieldNullableValue<AndroidTouchProcessor>("androidTouchProcessor")
        set(value) = setSuperFieldValue("androidTouchProcessor", value)

    private var accessibilityBridge
        get() = getSuperFieldNullableValue<AccessibilityBridge>("accessibilityBridge")
        set(value) = setSuperFieldValue("accessibilityBridge", value)

    private val onAccessibilityChangeListener
        get() = getSuperFieldValue<AccessibilityBridge.OnAccessibilityChangeListener>("onAccessibilityChangeListener")

    private val systemSettingsObserver
        get() = getSuperFieldValue<ContentObserver>("systemSettingsObserver")

    private val flutterEngineAttachmentListeners
        get() = getSuperFieldValue<Set<FlutterEngineAttachmentListener>>("flutterEngineAttachmentListeners")

    fun reattachToFlutterEngine() {
        if (flutterEngine == null) {
            return
        }
        Log.v(
            TAG,
            "Reattaching to a FlutterEngine: $flutterEngine"
        )

        // Instruct our FlutterRenderer that we are now its designated RenderSurface.
        val flutterRenderer = flutterEngine!!.renderer
        isFlutterUiDisplayed = flutterRenderer.isDisplayingFlutterUi
        renderSurface!!.attachToRenderer(flutterRenderer)
        flutterRenderer.addIsDisplayingFlutterUiListener(flutterUiDisplayListener)

        // Initialize various components that know how to process Android View I/O
        // in a way that Flutter understands.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            mouseCursorPlugin = MouseCursorPlugin(this, this.flutterEngine!!.mouseCursorChannel)
        }
        textInputPlugin = TextInputPlugin(
            this,
            this.flutterEngine!!.textInputChannel,
            this.flutterEngine!!.platformViewsController
        )
        try {
            textServicesManager =
                context.getSystemService(Context.TEXT_SERVICES_MANAGER_SERVICE) as TextServicesManager
            spellCheckPlugin =
                SpellCheckPlugin(textServicesManager!!, this.flutterEngine!!.spellCheckChannel)
        } catch (e: Exception) {
            Log.e(TAG, "TextServicesManager not supported by device, spell check disabled.")
        }
        localizationPlugin = this.flutterEngine!!.localizationPlugin
        keyboardManager = KeyboardManager(this)
        androidTouchProcessor =
            AndroidTouchProcessor(this.flutterEngine!!.renderer,  /*trackMotionEvents=*/false)
        accessibilityBridge = AccessibilityBridge(
            this,
            flutterEngine!!.accessibilityChannel,
            (context.getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager),
            context.contentResolver,
            this.flutterEngine!!.platformViewsController
        )
        accessibilityBridge!!.setOnAccessibilityChangeListener(onAccessibilityChangeListener)
        callSuperMethod(
            "resetWillNotDraw",
            accessibilityBridge!!.isAccessibilityEnabled,
            accessibilityBridge!!.isTouchExplorationEnabled
        )

        // Connect AccessibilityBridge to the PlatformViewsController within the FlutterEngine.
        // This allows platform Views to hook into Flutter's overall accessibility system.
        this.flutterEngine!!.platformViewsController.attachAccessibilityBridge(accessibilityBridge!!)
//        this.flutterEngine!!
//            .platformViewsController
//            .attachToFlutterRenderer(this.flutterEngine!!.renderer)

        // Inform the Android framework that it should retrieve a new InputConnection
        // now that an engine is attached.
        // TODO(mattcarroll): once this is proven to work, move this line ot TextInputPlugin
        textInputPlugin!!.inputMethodManager.restartInput(this)

        // Push View and Context related information from Android to Flutter.
        sendUserSettingsToFlutter()
        context
            .contentResolver
            .registerContentObserver(
                Settings.System.getUriFor(Settings.System.TEXT_SHOW_PASSWORD),
                false,
                systemSettingsObserver
            )
        callSuperMethod("sendViewportMetricsToFlutter")
        flutterEngine!!.platformViewsController.attachToView(this)

        // Notify engine attachment listeners of the attachment.
        for (listener in flutterEngineAttachmentListeners) {
            listener.onFlutterEngineAttachedToFlutterView(flutterEngine!!)
        }

        // If the first frame has already been rendered, notify all first frame listeners.
        // Do this after all other initialization so that listeners don't inadvertently interact
        // with a FlutterView that is only partially attached to a FlutterEngine.
        if (isFlutterUiDisplayed) {
            flutterUiDisplayListener.onFlutterUiDisplayed()
        }
    }
}