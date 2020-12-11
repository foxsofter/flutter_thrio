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
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.navigator.*
import com.hellobike.flutter.thrio.navigator.NavigationController
import com.hellobike.flutter.thrio.navigator.PageRoutes
import com.hellobike.flutter.thrio.navigator.getPageId

open class ThrioActivity : ThrioFlutterActivity() {

    override fun shouldAttachEngineToActivity(): Boolean {
        return true
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        return false
    }

    override fun onBackPressed() {
        val lastRoute = PageRoutes.lastRoute()
        if (lastRoute == null) {
            if (shouldMoveToBack()) {
                moveTaskToBack(true)
            }
        } else {
            PageRoutes.firstRouteHolder?.apply {
                if (pageId == intent.getPageId() && routes.count() < 2) {
                    if (shouldMoveToBack()) {
                        moveTaskToBack(true)
                    }
                    return
                }
            }
            ThrioNavigator.pop()
        }
    }

    // 重写这个方法，拦截是否隐藏到后台
    protected open fun shouldMoveToBack(): Boolean = true

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