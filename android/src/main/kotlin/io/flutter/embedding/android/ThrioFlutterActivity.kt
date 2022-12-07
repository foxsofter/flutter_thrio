/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 foxsofter
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

import android.content.Context
import android.content.pm.PackageManager
import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.IntCallback
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import com.foxsofter.flutter_thrio.extension.getPageId
import com.foxsofter.flutter_thrio.navigator.FlutterEngineFactory
import com.foxsofter.flutter_thrio.navigator.NAVIGATION_ROUTE_PAGE_ID_NONE
import com.foxsofter.flutter_thrio.navigator.NavigationController
import com.foxsofter.flutter_thrio.navigator.ThrioNavigator
import io.flutter.embedding.engine.FlutterEngine

open class ThrioFlutterActivity : FlutterActivity() {
    companion object {
        var isInitialUrlPushed = false
    }

    val engine: com.foxsofter.flutter_thrio.navigator.FlutterEngine?
        get() {
            val entrypoint = intent.getEntrypoint()
            val pageId = intent.getPageId()
            return FlutterEngineFactory.getEngine(pageId, entrypoint)
        }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineFactory.provideEngine(this)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        FlutterEngineFactory.cleanUpFlutterEngine(this)
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
        if (!isInitialUrlPushed && initialUrl?.isNotEmpty() == true) {
            isInitialUrlPushed = true
            NavigationController.Push.push(initialUrl!!, null, false) {}
        }
        super.onFlutterUiDisplayed()
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        return !FlutterEngineFactory.isMainEngine(pageId, entrypoint)
    }

    override fun onBackPressed() = ThrioNavigator.pop()

    // 重写这个方法，拦截是否隐藏到后台
    open fun shouldMoveToBack(): Boolean = false

    fun onPush(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPush(arguments, result)
    }

    fun onNotify(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onNotify(arguments, result)
    }

    fun onMaybePop(arguments: Map<String, Any?>?, result: IntCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onMaybePop(arguments, result)
    }

    fun onPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPop(arguments, result)
    }

    fun onPopTo(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPopTo(arguments, result)
    }

    fun onRemove(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onRemove(arguments, result)
    }

    fun onReplace(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onReplace(arguments, result)
    }

    fun onCanPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onCanPop(arguments, result)
    }

    private fun readInitialUrl() {
        val activityInfo =
            packageManager.getActivityInfo(componentName, PackageManager.GET_META_DATA)
        _initialUrl = if (activityInfo.metaData == null) "" else {
            activityInfo.metaData.getString("io.flutter.InitialUrl", "")
        }
    }
}