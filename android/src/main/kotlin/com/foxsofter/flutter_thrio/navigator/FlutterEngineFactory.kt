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

import android.content.Context
import com.foxsofter.flutter_thrio.extension.getEntrypoint
import com.foxsofter.flutter_thrio.extension.getPageId
import io.flutter.embedding.android.ThrioFlutterActivity

object FlutterEngineFactory : PageObserver, RouteObserver {

    private val engineGroups = mutableMapOf<String, FlutterEngineGroup>()

    internal var isMultiEngineEnabled = false

    fun startup(
        context: Context,
        entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT,
        readyListener: FlutterEngineReadyListener? = null
    ) {
        val ep = getEntrypoint(entrypoint)
        var engineGroup = engineGroups[ep]
        if (engineGroup == null) {
            engineGroup = FlutterEngineGroup(ep)
            engineGroups[ep] = engineGroup
        }
        engineGroup.startup(context, readyListener)
    }

    // 仅用于让 ThrioFlutterActivity 调用
    fun provideEngine(activity: ThrioFlutterActivity): io.flutter.embedding.engine.FlutterEngine {
        val entrypoint = getEntrypoint(activity.intent.getEntrypoint())
        return engineGroups[entrypoint]?.provideEngine(activity)
            ?: throw RuntimeException("FlutterEngine not exists")
    }

    // 仅用于让 ThrioFlutterActivity 调用
    fun cleanUpFlutterEngine(activity: ThrioFlutterActivity) {
        val entrypoint = getEntrypoint(activity.intent.getEntrypoint())
        val pageId = activity.intent.getPageId()
        engineGroups[entrypoint]?.cleanUpFlutterEngine(pageId)
    }

    // 获取 FlutterEngine 的实例
    fun getEngine(
        pageId: Int,
        entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
    ): FlutterEngine? {
        val ep = getEntrypoint(entrypoint)
        return engineGroups[ep]?.getEngine(pageId)
    }

    // 获取 entrypoint 的所有 FlutterEngine 实例
    fun getEngines(
        entrypoint: String = NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT
    ): Iterable<FlutterEngine> {
        val ep = getEntrypoint(entrypoint)
        return engineGroups[ep]?.engines ?: listOf()
    }

    // 判断是否匹配的是主引擎
    fun isMainEngine(pageId: Int, entrypoint: String): Boolean {
        val ep = getEntrypoint(entrypoint)
        return engineGroups[ep]?.isMainEngine(pageId) ?: false
    }

    private fun getEntrypoint(entrypoint: String): String =
        if (!isMultiEngineEnabled) NAVIGATION_FLUTTER_ENTRYPOINT_DEFAULT else entrypoint

    fun setModuleContextValue(value: Any?, key: String) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.moduleContextChannel.invokeMethod("set", mutableMapOf(key to value))
            }
        }
    }

    override fun willAppear(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.pageChannel.willAppear(routeSettings)
            }
        }
    }

    override fun didAppear(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.pageChannel.didAppear(routeSettings)
            }
        }
    }

    override fun willDisappear(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.pageChannel.willDisappear(routeSettings)
            }
        }
    }

    override fun didDisappear(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.pageChannel.didDisappear(routeSettings)
            }
        }
    }

    override fun didPush(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.routeChannel.didPush(routeSettings)
            }
        }
    }

    override fun didPop(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.routeChannel.didPop(routeSettings)
            }
        }
    }

    override fun didPopTo(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.routeChannel.didPopTo(routeSettings)
            }
        }
    }

    override fun didRemove(routeSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.routeChannel.didRemove(routeSettings)
            }
        }
    }

    override fun didReplace(newRouteSettings: RouteSettings, oldRouteSettings: RouteSettings) {
        engineGroups.values.forEach { engineGroup ->
            engineGroup.engines.forEach { engine ->
                engine.routeChannel.didReplace(newRouteSettings, oldRouteSettings)
            }
        }
    }
}