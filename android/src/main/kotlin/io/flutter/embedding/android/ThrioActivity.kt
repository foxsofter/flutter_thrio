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

package io.flutter.embedding.android

import android.annotation.SuppressLint
import android.content.Intent
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory
import com.hellobike.flutter.thrio.navigator.NavigationController
import com.hellobike.flutter.thrio.navigator.RouteSendHandler

open class ThrioActivity : ThrioFlutterActivity(), RouteSendHandler {

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.extras?.let { this.intent.putExtras(it) }
    }

    @SuppressLint("VisibleForTests")
    override fun finish() {
        super.finish()
//        super.delegate?.onStop()
//        super.delegate?.onDetach()
    }

    override fun shouldAttachEngineToActivity(): Boolean {
        return true
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    override fun onBackPressed() {
        NavigationController.Pop.pop(context, null, true)
    }

    override fun onPush(arguments: Any?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onPush(arguments, result)
    }

    override fun onNotify(arguments: Any?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onNotify(arguments, result)
    }

    override fun onPop(arguments: Any?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onPop(arguments, result)
    }

    override fun onPopTo(arguments: Any?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onPopTo(arguments, result)
    }

    override fun onRemove(arguments: Any?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.onRemove(arguments, result)
    }

}