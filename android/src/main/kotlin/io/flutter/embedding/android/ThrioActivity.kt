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

package io.flutter.embedding.android

import android.annotation.SuppressLint
import android.content.Intent
import com.hellobike.flutter.thrio.Result
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory
import com.hellobike.flutter.thrio.navigator.NavigationController
import com.hellobike.flutter.thrio.navigator.PageRoute

open class ThrioActivity : FlutterActivity() {

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.extras?.let { this.intent.putExtras(it) }
    }

    @SuppressLint("VisibleForTests")
    override fun finish() {
        super.finish()
        super.delegate.onStop()
        super.delegate.onDetach()
    }

    override fun onBackPressed() {
        NavigationController.Navigator.pop(context, null, true)
    }

    internal fun onPush(record: PageRoute, isNested: Boolean, result: Result) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onPush(record, isNested, result)
    }

    internal fun onPop(record: PageRoute, result: Result) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onPop(record, result)
    }

    internal fun onRemove(url: String, index: Int, animated: Boolean, result: Result) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onRemove(url, index, animated, result)
    }

    internal fun onPopTo(url: String, index: Int, animated: Boolean, result: Result) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onPopTo(url, index, animated, result)
    }

    internal fun onNotify(url: String, index: Int, name: String, params: Any?) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onNotify(url, index, name, params)
    }

}