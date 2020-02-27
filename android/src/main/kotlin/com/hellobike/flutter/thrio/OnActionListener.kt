package com.hellobike.flutter.thrio

import com.hellobike.thrio.Result


internal interface OnActionListener {

    fun onPush(url: String, index: Int, params: Map<String, Any>, animated: Boolean, result: Result)

    fun onPop(url: String, index: Int, animated: Boolean, result: Result)

    fun onRemove(url: String, index: Int, animated: Boolean, result: Result)

    fun onPopTo(url: String, index: Int, animated: Boolean, result: Result)
}