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

package com.hellobike.flutter.thrio.navigator

import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class RouteReceiveChannel(private val entrypoint: String,
                          private var readyListener: EngineReadyListener? = null)
    : MethodChannel.MethodCallHandler {

    private fun push(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val params = call.argument<Any>("params")
        val animated = call.argument<Boolean>("animated") ?: true

        NavigationController.Push.push(url, params, animated, entrypoint) {
            result.success(it)
        }
    }

    private fun pop(call: MethodCall, result: MethodChannel.Result) {
        val params = call.argument<Any>("params")
        val animated = call.argument<Boolean>("animated") ?: true

        NavigationController.Pop.pop(params, animated) { result.success(it) }
    }

    private fun remove(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val index = call.argument<Int>("index") ?: 0
        if (index < 0) {
            result.success(false)
            return
        }

        val animated = call.argument<Boolean>("animated") ?: true

        NavigationController.Remove.remove(url, index, animated) { result.success(it) }
    }

    private fun popTo(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val index = call.argument<Int>("index") ?: 0
        if (index < 0) {
            result.success(false)
            return
        }
        val animated = call.argument<Boolean>("animated") ?: true

        NavigationController.PopTo.popTo(url, index, animated) { result.success(it) }
    }

    private fun notify(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.success(false)
            return
        }
        val index = call.argument<Int>("index") ?: 0
        if (index < 0) {
            result.success(false)
            return
        }
        val name = call.argument<String>("name")
        if (name.isNullOrBlank()) {
            result.success(false)
            return
        }
        val params = call.argument<Any>("params")

        NavigationController.Notify.notify(url, index, name, params) { result.success(it) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.e("Thrio", "flutter call method ${call.method}")
        when (call.method) {
            "ready" -> {
                readyListener?.onReady(entrypoint)
                readyListener = null
            }
            "push" -> push(call, result)
            "notify" -> notify(call, result)
            "pop" -> pop(call, result)
            "remove" -> remove(call, result)
            "popTo" -> popTo(call, result)
            "setPopDisabled" -> {
            }
            "hotRestart" -> {
            }
            "registerUrls" -> {
            }
            "unregisterUrls" -> {
            }
            else -> {
                Log.e("Thrio", "flutter call method ${call.method} notImplemented")
                result.notImplemented()
            }
        }
    }
}
