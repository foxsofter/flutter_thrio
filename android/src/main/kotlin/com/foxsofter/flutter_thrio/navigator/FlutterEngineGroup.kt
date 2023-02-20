package com.foxsofter.flutter_thrio.navigator

import android.app.Activity
import com.foxsofter.flutter_thrio.extension.getPageId
import com.foxsofter.flutter_thrio.module.ThrioModule
import io.flutter.embedding.engine.ThrioFlutterEngine

/// 管理主引擎及其fork出来的引擎，这里用 entrypoint 来标识，不同的 entrypoint 尽用来支持运行不同的编译产物
/// 虽然 fork 引擎可以支持不同的同一份编译产物的不同的 entrypoint，当前场景下没有太大意义
///
open class FlutterEngineGroup constructor(private var entrypoint: String) {
    // return all FlutterEngine
    val engines get() = engineMap.values

    // 返回 pageId 是否匹配的是主引擎
    fun isMainEngine(pageId: Int): Boolean = engineMap[pageId] == mainEngine

    // 根据 pageId 获取对应引擎实例
    fun getEngine(pageId: Int): FlutterEngine? = engineMap[pageId]

    // 仅用于让 ThrioFlutterActivity 或 ThrioFlutterFragmentActivity 调用
    fun provideEngine(activity: Activity): ThrioFlutterEngine {
        val pageId = activity.intent.getPageId()
        if (engineMap.contains(pageId)) {
            return engineMap[pageId]!!.engine
        }
        val newEngine = startup(activity)
        newEngine.pageId = pageId
        engineMap[pageId] = newEngine
        return newEngine.engine
    }

    // 仅用于让 ThrioFlutterActivity 或 ThrioFlutterFragmentActivity 调用
    fun cleanUpFlutterEngine(activity: Activity) {
        val pageId = activity.intent.getPageId()
        val engine = engineMap[pageId]
        if (engine != mainEngine) {
            engine?.destroy()
            engineMap.remove(pageId)
        }
    }

    // 存储当前所有的引擎实例，key 为 pageId
    private val engineMap = mutableMapOf<Int, FlutterEngine>()

    // 主引擎，多引擎模式下懒加载，单引擎模式下可以预加载
    private var mainEngine: FlutterEngine? = null

    // 启动一份引擎，如果主引擎还没启动则启动之，如果主引擎已经启动，则 fork 一个引擎
    private fun startup(activity: Activity): FlutterEngine {
        val pageId = activity.intent.getPageId()
        var engine = engineMap[pageId]
        if (engine != null) {
            return engine
        }
        val flutterEngine =
            mainEngine?.engine?.fork(activity, entrypoint, null, null)
                ?: ThrioFlutterEngine(activity)
        engine =
            FlutterEngine(
                entrypoint,
                flutterEngine,
                mainEngine == null,
                object : FlutterEngineReadyListener {
                    override fun onReady(engine: FlutterEngine) {
                        ThrioModule.root.syncModuleContext(engine)
                    }
                })
        engineMap[pageId] = engine
        mainEngine = mainEngine ?: engine
        return engine
    }
}