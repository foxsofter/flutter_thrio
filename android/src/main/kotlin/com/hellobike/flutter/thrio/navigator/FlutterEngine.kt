// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

package com.hellobike.flutter.thrio.navigator

import android.content.Context
import com.hellobike.flutter.thrio.Result
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.view.FlutterMain

data class FlutterEngine(private val context: Context, private val entrypoint: String) {

    private var entryPoint: String = entrypoint
    var flutterEngine: FlutterEngine = FlutterEngine(context)
    var sendChannel: RouteSendChannel
    var receiveChannel: RouteReceiveChannel

    var routeObserverChannel: RouteObserverChannel
    var pageObserverChannel: PageObserverChannel

    init {
        sendChannel = RouteSendChannel(flutterEngine.dartExecutor, entrypoint)
        receiveChannel = RouteReceiveChannel(entrypoint)
        sendChannel.setMethodCallHandler(receiveChannel)

        routeObserverChannel = RouteObserverChannel(flutterEngine.dartExecutor)
        pageObserverChannel = PageObserverChannel(flutterEngine.dartExecutor)

        val dartEntrypoint = DartExecutor.DartEntrypoint(FlutterMain.findAppBundlePath(), entrypoint)
        flutterEngine.dartExecutor.executeDartEntrypoint(dartEntrypoint)

        FlutterEngineCache.getInstance().put(entryPoint, flutterEngine)
    }

    fun onPush(record: PageRoute, isNested: Boolean, result: Result) {
        sendChannel.onPush(record.url, record.index, record.params, record.animated, isNested, result)
    }

    fun onPop(record: PageRoute, result: Result) {
        sendChannel.onPop(record.url, record.index, record.resultParams, record.animated, result)
    }

    fun onRemove(url: String, index: Int, animated: Boolean, result: Result) {
        sendChannel.onRemove(url, index, animated, result)
    }

    fun onPopTo(url: String, index: Int, animated: Boolean, result: Result) {
        sendChannel.onPopTo(url, index, animated, result)
    }

    fun onNotify(url: String, index: Int, name: String, params: Any?) {
        sendChannel.onNotify(url, index, name, params)
    }


}