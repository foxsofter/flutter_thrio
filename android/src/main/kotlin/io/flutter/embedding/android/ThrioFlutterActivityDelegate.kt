/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2022 foxsofter
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

import android.app.Activity
import android.content.Context
import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.IntCallback
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import com.foxsofter.flutter_thrio.extension.getPageId
import com.foxsofter.flutter_thrio.navigator.FlutterEngineFactory
import com.foxsofter.flutter_thrio.navigator.NAVIGATION_ROUTE_PAGE_ID_NONE
import com.foxsofter.flutter_thrio.navigator.PageRoutes
import io.flutter.embedding.engine.FlutterEngine

open class ThrioFlutterActivityDelegate(val activity: Activity) : ThrioFlutterActivityBase {
    override val engine: com.foxsofter.flutter_thrio.navigator.FlutterEngine?
        get() {
            val pageId = activity.intent.getPageId()
            val holder = PageRoutes.lastRouteHolder(pageId) ?: return null
            return FlutterEngineFactory.getEngine(pageId, holder.entrypoint)
        }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineFactory.provideEngine(activity)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        FlutterEngineFactory.cleanUpFlutterEngine(activity)
    }

    var lastClickTime = System.currentTimeMillis()

    override fun onBackPressed() {
        val now = System.currentTimeMillis()
        if (now - lastClickTime <= 400) {
            return
        }
        lastClickTime = now
        engine?.engine?.navigationChannel?.popRoute()
    }

    override fun shouldDestroyEngineWithHost(): Boolean {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        return !FlutterEngineFactory.isMainEngine(pageId, entrypoint)
    }

    override fun onPush(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPush(arguments, result)
    }

    override fun onNotify(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onNotify(arguments, result)
    }

    override fun onMaybePop(arguments: Map<String, Any?>?, result: IntCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onMaybePop(arguments, result)
    }

    override fun onPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPop(arguments, result)
    }

    override fun onPopTo(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onPopTo(arguments, result)
    }

    override fun onRemove(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onRemove(arguments, result)
    }

    override fun onReplace(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onReplace(arguments, result)
    }

    override fun onCanPop(arguments: Map<String, Any?>?, result: BooleanCallback) {
        val pageId = activity.intent.getPageId()
        if (pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) throw IllegalStateException("pageId must not be null")
        val entrypoint = activity.intent.getEntrypoint()
        val engine = FlutterEngineFactory.getEngine(pageId, entrypoint)
            ?: throw IllegalStateException("engine must not be null")
        engine.sendChannel.onCanPop(arguments, result)
    }
}