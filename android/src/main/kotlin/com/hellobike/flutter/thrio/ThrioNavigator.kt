package com.hellobike.flutter.thrio

import android.content.Context
import com.hellobike.flutter.thrio.navigator.NavigatorManager
import com.hellobike.flutter.thrio.navigator.ThrioActivity

object ThrioNavigator {

    fun push(Context: Context, url: String) {
        ThrioActivity.push(Context, url)
    }

    fun registerPageBuilder(url: String, builder: PageBuilder) {
        NavigatorManager.addPageBuilder(url, builder)
    }
}