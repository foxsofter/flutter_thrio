package io.flutter.embedding.android

import android.content.pm.PackageManager
import com.foxsofter.flutter_thrio.navigator.NavigationController

open class ThrioRootFragment: ThrioFlutterFragment() {
    companion object {
        var isInitialUrlPushed = false
    }

    private var _initialUrl: String? = null

    protected open val initialUrl: String?
        get() {
            if (_initialUrl == null) {
                readInitialUrl()
            }
            return _initialUrl!!
        }

    override fun onFlutterUiDisplayed() {
        if (!isInitialUrlPushed && initialUrl?.isNotEmpty() == true) {
            isInitialUrlPushed = true
            NavigationController.Push.push(initialUrl!!, null, false) {}
        }
        super.onFlutterUiDisplayed()
    }

    private fun readInitialUrl() {
        val activity = requireActivity()
        val activityInfo =
            activity.packageManager.getActivityInfo(
                activity.componentName,
                PackageManager.GET_META_DATA
            )
        _initialUrl = if (activityInfo.metaData == null) "" else {
            activityInfo.metaData.getString("io.flutter.InitialUrl", "")
        }
    }
}