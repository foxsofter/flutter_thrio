package io.flutter.embedding.android

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.os.Parcel
import android.os.Parcelable
import android.util.AttributeSet
import android.view.View
import android.widget.FrameLayout
import androidx.annotation.Keep
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.renderer.FlutterUiDisplayListener

/**
 * `View` that displays a [SplashScreen] until a given [FlutterView] renders its
 * first frame.
 */
/* package */
internal class ThrioFlutterSplashView @JvmOverloads constructor(
        context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0) : FrameLayout(context, attrs, defStyleAttr) {
    private var splashScreen: SplashScreen? = null
    private var flutterView: ThrioFlutterView? = null
    private var splashScreenView: View? = null
    private var splashScreenState: Bundle? = null
    private var transitioningIsolateId: String? = null
    private var previousCompletedSplashIsolate: String? = null
    private val flutterEngineAttachmentListener: ThrioFlutterView.FlutterEngineAttachmentListener by lazy {
        @SuppressLint("VisibleForTests")
        object : ThrioFlutterView.FlutterEngineAttachmentListener {
            override fun onFlutterEngineAttachedToFlutterView(engine: FlutterEngine) {
                flutterView!!.removeFlutterEngineAttachmentListener(this)
                displayFlutterViewWithSplash((flutterView)!!, splashScreen)
            }

            override fun onFlutterEngineDetachedFromFlutterView() {}
        }
    }
    private val flutterUiDisplayListener: FlutterUiDisplayListener by lazy {
        object : FlutterUiDisplayListener {
            override fun onFlutterUiDisplayed() {
                if (splashScreen != null) {
                    transitionToFlutter()
                }
            }

            override fun onFlutterUiNoLongerDisplayed() {
                // no-op
            }
        }
    }
    private val onTransitionComplete: Runnable = Runnable {
        removeView(splashScreenView)
        previousCompletedSplashIsolate = transitioningIsolateId
    }

    override fun onSaveInstanceState(): Parcelable? {
        val superState: Parcelable? = super.onSaveInstanceState()
        val savedState = SavedState(superState)
        savedState.previousCompletedSplashIsolate = previousCompletedSplashIsolate
        savedState.splashScreenState = if (splashScreen != null) splashScreen!!.saveSplashScreenState() else null
        return savedState
    }

    override fun onRestoreInstanceState(state: Parcelable) {
        val savedState: SavedState = state as SavedState
        super.onRestoreInstanceState(savedState.superState)
        previousCompletedSplashIsolate = savedState.previousCompletedSplashIsolate
        splashScreenState = savedState.splashScreenState
    }

    /**
     * Displays the given `splashScreen` on top of the given `flutterView` until Flutter
     * has rendered its first frame, then the `splashScreen` is transitioned away.
     *
     *
     * If no `splashScreen` is provided, this `FlutterSplashView` displays the given
     * `flutterView` on its own.
     */
    fun displayFlutterViewWithSplash(
            flutterView: ThrioFlutterView, splashScreen: SplashScreen?) {
        // If we were displaying a previous ThrioFlutterView, remove it.
        if (this.flutterView != null) {
            this.flutterView!!.removeOnFirstFrameRenderedListener(flutterUiDisplayListener)
            removeView(this.flutterView)
        }
        // If we were displaying a previous splash screen View, remove it.
        if (splashScreenView != null) {
            removeView(splashScreenView)
        }

        // Display the new ThrioFlutterView.
        this.flutterView = flutterView
        addView(flutterView)
        this.splashScreen = splashScreen

        // Display the new splash screen, if needed.
        if (splashScreen != null) {
            if (isSplashScreenNeededNow) {
                Log.v(TAG, "Showing splash screen UI.")
                // This is the typical case. A FlutterEngine is attached to the ThrioFlutterView and we're
                // waiting for the first frame to render. Show a splash UI until that happens.
                splashScreenView = splashScreen.createSplashView(context, splashScreenState)
                addView(splashScreenView)
                flutterView.addOnFirstFrameRenderedListener(flutterUiDisplayListener)
            } else if (isSplashScreenTransitionNeededNow) {
                Log.v(
                        TAG,
                        "Showing an immediate splash transition to Flutter due to previously interrupted transition.")
                splashScreenView = splashScreen.createSplashView(context, splashScreenState)
                addView(splashScreenView)
                transitionToFlutter()
            } else if (!flutterView.isAttachedToFlutterEngine) {
                Log.v(
                        TAG,
                        "ThrioFlutterView is not yet attached to a FlutterEngine. Showing nothing until a FlutterEngine is attached.")
                flutterView.addFlutterEngineAttachmentListener(flutterEngineAttachmentListener)
            }
        }
    }

    /**
     * Returns true if current conditions require a splash UI to be displayed.
     *
     *
     * This method does not evaluate whether a previously interrupted splash transition needs to
     * resume. See [.isSplashScreenTransitionNeededNow] to answer that question.
     */
    private val isSplashScreenNeededNow: Boolean
        private get() = ((flutterView != null
                ) && flutterView!!.isAttachedToFlutterEngine
                && !flutterView!!.hasRenderedFirstFrame()
                && !hasSplashCompleted())

    /**
     * Returns true if a previous splash transition was interrupted by recreation, e.g., an
     * orientation change, and that previous transition should be resumed.
     *
     *
     * Not all splash screens are capable of remembering their transition progress. In those cases,
     * this method will return false even if a previous visual transition was interrupted.
     */
    private val isSplashScreenTransitionNeededNow: Boolean
        private get() {
            return ((flutterView != null
                    ) && flutterView!!.isAttachedToFlutterEngine
                    && (splashScreen != null
                    ) && splashScreen!!.doesSplashViewRememberItsTransition()
                    && wasPreviousSplashTransitionInterrupted())
        }

    /**
     * Returns true if a splash screen was transitioning to a Flutter experience and was then
     * interrupted, e.g., by an Android configuration change. Returns false otherwise.
     *
     *
     * Invoking this method expects that a `flutterView` exists and it is attached to a
     * `FlutterEngine`.
     */
    private fun wasPreviousSplashTransitionInterrupted(): Boolean {
        if (flutterView == null) {
            throw IllegalStateException((
                    "Cannot determine if previous splash transition was "
                            + "interrupted when no ThrioFlutterView is set."))
        }
        if (!flutterView!!.isAttachedToFlutterEngine) {
            throw IllegalStateException(
                    ("Cannot determine if previous splash transition was "
                            + "interrupted when no FlutterEngine is attached to our ThrioFlutterView. This question "
                            + "depends on an isolate ID to differentiate Flutter experiences."))
        }
        return flutterView!!.hasRenderedFirstFrame() && !hasSplashCompleted()
    }

    /**
     * Returns true if a splash UI for a specific Flutter experience has already completed.
     *
     *
     * A "specific Flutter experience" is defined as any experience with the same Dart isolate ID.
     * The purpose of this distinction is to prevent a situation where a user gets past a splash UI,
     * rotates the device (or otherwise triggers a recreation) and the splash screen reappears.
     *
     *
     * An isolate ID is deemed reasonable as a key for a completion event because a Dart isolate
     * cannot be entered twice. Therefore, a single Dart isolate cannot return to an "un-rendered"
     * state after having previously rendered content.
     */
    private fun hasSplashCompleted(): Boolean {
        if (flutterView == null) {
            throw IllegalStateException(
                    "Cannot determine if splash has completed when no ThrioFlutterView " + "is set.")
        }
        if (!flutterView!!.isAttachedToFlutterEngine) {
            throw IllegalStateException(
                    ("Cannot determine if splash has completed when no "
                            + "FlutterEngine is attached to our ThrioFlutterView. This question depends on an isolate ID "
                            + "to differentiate Flutter experiences."))
        }

        // A null isolate ID on a non-null FlutterEngine indicates that the Dart isolate has not
        // been initialized. Therefore, no frame has been rendered for this engine, which means
        // no splash screen could have completed yet.
        return (flutterView!!.attachedFlutterEngine!!.dartExecutor.isolateServiceId != null
                && (flutterView!!
                .attachedFlutterEngine
                ?.dartExecutor
                ?.isolateServiceId
                == previousCompletedSplashIsolate))
    }

    /**
     * Transitions a splash screen to the Flutter UI.
     *
     *
     * This method requires that our ThrioFlutterView be attached to an engine, and that engine have a
     * Dart isolate ID. It also requires that a `splashScreen` exist.
     */
    private fun transitionToFlutter() {
        transitioningIsolateId = flutterView!!.attachedFlutterEngine!!.dartExecutor.isolateServiceId
        Log.v(TAG, "Transitioning splash screen to a Flutter UI. Isolate: $transitioningIsolateId")
        splashScreen!!.transitionToFlutter(onTransitionComplete)
    }

    @Keep
    class SavedState : BaseSavedState {
        var previousCompletedSplashIsolate: String? = null
        var splashScreenState: Bundle? = null

        internal constructor(superState: Parcelable?) : super(superState) {}
        internal constructor(source: Parcel) : super(source) {
            previousCompletedSplashIsolate = source.readString()
            splashScreenState = source.readBundle(javaClass.classLoader)
        }

        override fun writeToParcel(out: Parcel, flags: Int) {
            super.writeToParcel(out, flags)
            out.writeString(previousCompletedSplashIsolate)
            out.writeBundle(splashScreenState)
        }

        companion object {
            var CREATOR: Parcelable.Creator<SavedState?> = object : Parcelable.Creator<SavedState?> {
                override fun createFromParcel(source: Parcel): SavedState? {
                    return SavedState(source)
                }

                override fun newArray(size: Int): Array<SavedState?> {
                    return arrayOfNulls(size)
                }
            }
        }
    }

    companion object {
        private const val TAG: String = "FlutterSplashView"
    }

    init {
        isSaveEnabled = true
    }
}
