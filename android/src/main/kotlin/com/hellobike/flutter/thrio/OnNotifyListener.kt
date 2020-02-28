package com.hellobike.flutter.thrio

interface OnNotifyListener {
    fun onNotify(url: String, index: Int, name: String, params: Map<String, Any>)
}