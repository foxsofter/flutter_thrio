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

package com.foxsofter.flutter_thrio.navigator

import android.app.Activity
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import com.foxsofter.flutter_thrio.module.ThrioModule
import io.flutter.embedding.engine.ThrioFlutterEngine

object FlutterEngineFactory : PageObserver, RouteObserver {

    private var firstEntrypoint: String = "main"

    private val engines = mutableMapOf<String, FlutterEngine>()

    internal var isMultiEngineEnabled = false

    // 仅用于让 ThrioFlutterFragmentActivity 调用
    fun provideEngine(activity: Activity): io.flutter.embedding.engine.FlutterEngine {
        val entrypoint = getEntrypoint(activity.intent.getEntrypoint())
        var engine = engines[entrypoint]
        if (engine == null) {
            engine =
                FlutterEngine(
                    entrypoint,
                    ThrioFlutterEngine(activity),
                    object : FlutterEngineReadyListener {
                        override fun onReady(engine: FlutterEngine) {
                            ThrioModule.root.syncModuleContext(engine)
                        }
                    })
            if (engines.isEmpty()) {
                firstEntrypoint = entrypoint
            }
            engines[entrypoint] = engine
        }
        return engine.flutterEngine
    }

    // 仅用于让 ThrioFlutterFragmentActivity 调用
    fun cleanUpFlutterEngine(activity: Activity) {
        val entrypoint = getEntrypoint(activity.intent.getEntrypoint())
        if (entrypoint != firstEntrypoint) {
            engines.remove(entrypoint)?.destroy()
        }
    }

    // 获取 FlutterEngine 的实例
    fun getEngine(
        entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
    ): FlutterEngine? {
        val ep = getEntrypoint(entrypoint)
        return engines[ep]
    }

    fun getEngines(): List<FlutterEngine> {
        return engines.values.toList()
    }

    // 判断是否匹配的是主引擎
    fun isMainEngine(entrypoint: String): Boolean {
        return firstEntrypoint == entrypoint
    }

    private fun getEntrypoint(entrypoint: String): String =
        if (!isMultiEngineEnabled) NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT else entrypoint

    fun setModuleContextValue(value: Any?, key: String) {
        engines.values.forEach { engine ->
            engine.moduleContextChannel.invokeMethod("set", mutableMapOf(key to value))
        }
    }

    override fun willAppear(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.pageChannel.willAppear(routeSettings)
        }
    }

    override fun didAppear(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.pageChannel.didAppear(routeSettings)
        }
    }

    override fun willDisappear(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.pageChannel.willDisappear(routeSettings)
        }
    }

    override fun didDisappear(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.pageChannel.didDisappear(routeSettings)
        }
    }

    override fun didPush(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.routeChannel.didPush(routeSettings)
        }
    }

    override fun didPop(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.routeChannel.didPop(routeSettings)
        }
    }

    override fun didPopTo(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.routeChannel.didPopTo(routeSettings)
        }
    }

    override fun didRemove(routeSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.routeChannel.didRemove(routeSettings)
        }
    }

    override fun didReplace(newRouteSettings: RouteSettings, oldRouteSettings: RouteSettings) {
        engines.values.forEach { engine ->
            engine.routeChannel.didReplace(newRouteSettings, oldRouteSettings)
        }
    }
}