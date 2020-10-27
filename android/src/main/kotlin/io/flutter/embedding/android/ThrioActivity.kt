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

import android.content.Intent
import androidx.lifecycle.Lifecycle
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory
import com.hellobike.flutter.thrio.navigator.NavigationController
import java.lang.ref.WeakReference

open class ThrioActivity : ThrioFlutterActivity() {

    private var flutterSurfaceView : WeakReference<out FlutterSurfaceView>? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.extras?.let { this.intent.putExtras(it) }
    }

    override fun onFlutterSurfaceViewCreated(flutterSurfaceView: FlutterSurfaceView) {
        this.flutterSurfaceView = WeakReference(flutterSurfaceView)
    }

    override fun shouldAttachEngineToActivity(): Boolean {
        return true
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    override fun onBackPressed() {
        NavigationController.Pop.pop()
    }

    fun onPush(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPush(arguments, result)
    }

    fun onNotify(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onNotify(arguments, result)
    }

    fun onPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPop(arguments, result)
    }

    fun onPopTo(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPopTo(arguments, result)
    }

    fun onRemove(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val id = cachedEngineId ?: throw IllegalStateException("cachedEngineId must not be null")
        val engine = FlutterEngineFactory.getEngine(id)
                ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onRemove(arguments, result)
    }

}