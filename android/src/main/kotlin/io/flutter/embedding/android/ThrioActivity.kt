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

import android.content.pm.PackageManager
import android.os.Bundle
import com.hellobike.flutter.thrio.BooleanCallback
import com.hellobike.flutter.thrio.NullableBooleanCallback
import com.hellobike.flutter.thrio.extension.getEntrypoint
import com.hellobike.flutter.thrio.navigator.*

open class ThrioActivity : ThrioFlutterActivity() {
    companion object {
        var isPushed = false
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        intent.putExtra(NAVIGATION_ROUTE_ENTRYPOINT_KEY, cachedEngineId)

        super.onCreate(savedInstanceState)
    }

    private var _initialEntrypoint: String? = null

    override fun getCachedEngineId(): String? {
        if (_initialEntrypoint == null) {
            _initialEntrypoint =
                if (!FlutterEngineFactory.isMultiEngineEnabled) NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
                else if (initialUrl?.isEmpty() == true) ""
                else initialUrl?.getEntrypoint()
        }
        return if (_initialEntrypoint?.isNotEmpty() == true) _initialEntrypoint else super.getCachedEngineId()
    }

    private var _initialUrl: String? = null

    protected open val initialUrl: String?
        get() {
            if (_initialUrl == null) {
                readInitialUrl()
            }
            return _initialUrl!!
        }

    override fun onFlutterUiDisplayed() {
        if (!isPushed && initialUrl?.isNotEmpty() == true) {
            isPushed = true
            NavigationController.Push.push(initialUrl!!, null, false) {}
        }
        super.onFlutterUiDisplayed()
    }

    override fun shouldAttachEngineToActivity(): Boolean = true

    override fun shouldDestroyEngineWithHost(): Boolean = false

    override fun onBackPressed() = ThrioNavigator.pop()

    // 重写这个方法，拦截是否隐藏到后台
    open fun shouldMoveToBack(): Boolean = true

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

    fun onPop(arguments: Map<String, Any?>?, result: NullableBooleanCallback) {
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

    private fun readInitialUrl() {
        val activityInfo =
            packageManager.getActivityInfo(componentName, PackageManager.GET_META_DATA)
        _initialUrl = if (activityInfo.metaData == null) "" else {
            activityInfo.metaData.getString("io.flutter.InitialUrl", "")
        }
    }
}