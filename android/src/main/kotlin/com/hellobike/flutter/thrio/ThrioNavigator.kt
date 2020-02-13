package com.hellobike.flutter.thrio

import android.content.Context
import com.hellobike.flutter.thrio.navigator.NavigationController
import com.hellobike.flutter.thrio.navigator.ThrioActivity

object ThrioNavigator {

    fun push(Context: Context, url: String) {
        ThrioActivity.push(Context, url)
    }

    fun registerNavigationBuilder(url: String, builder: NavigationBuilder) {
        NavigationController.registerNavigationBuilder(url, builder)
    }
}