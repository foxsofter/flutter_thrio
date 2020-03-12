package com.hellobike.flutter.thrio.navigator

internal data class NavigatorFlutterEngine(private val id: Int) {
    var entryPoint: String? = null
    var sendChannel: NavigatorSendChannel? = null
    var receiveChannel: NavigatorReceiveChannel? = null
}