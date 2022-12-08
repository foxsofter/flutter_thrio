package com.foxsofter.flutter_thrio.navigator

import android.content.Context
import com.foxsofter.flutter_thrio.extension.getPageId
import io.flutter.embedding.android.ThrioFlutterActivity
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
    fun getEngine(pageId: Int): FlutterEngine? {
        if (engineMap.contains(pageId)) {
            return engineMap[pageId]
        }
        // 被获取后，放到 engines 中并清空
        currentEngine?.let { engine ->
            engine.pageId = pageId
            engineMap[pageId] = engine
        }
        currentEngine = null
        return engineMap[pageId]
    }

    // 仅用于让 ThrioFlutterActivity 调用
    fun provideEngine(activity: ThrioFlutterActivity): ThrioFlutterEngine {
        val pageId = activity.intent.getPageId()
        if (engineMap.contains(pageId)) {
            return engineMap[pageId]?.engine ?: throw RuntimeException("FlutterEngine not exists")
        }
        if (currentEngine == null) {
            currentEngine = startup(activity)
        }
        // 被获取后，放到 engines 中并清空
        currentEngine?.let { engine ->
            engine.pageId = pageId
            engineMap[pageId] = engine
        }
        val flutterEngine = currentEngine?.engine
        currentEngine = null
        return flutterEngine ?: throw RuntimeException("FlutterEngine not ready")
    }

    // 仅用于让 ThrioFlutterActivity 调用
    fun cleanUpFlutterEngine(pageId: Int) {
        val engine = engineMap[pageId]
        if (engine == mainEngine) {
            mainEngine?.pageId = NAVIGATION_ROUTE_PAGE_ID_NONE
        } else {
            engine?.destroy()
            engineMap.remove(pageId)
        }
    }

    // 存储当前所有的引擎实例，key 为 pageId
    private val engineMap = mutableMapOf<Int, FlutterEngine>()

    // 主引擎，多引擎模式下懒加载，单引擎模式下可以预加载
    private var mainEngine: FlutterEngine? = null

    // 当前引擎，标识当前组正在被启动的引擎，当收到 ready 回调后标识引擎启动结束
    private var currentEngine: FlutterEngine? = null

    // 标识当前是否正在启动引擎
    private var isRunning = false

    // 启动一份引擎，如果主引擎还没启动则启动之，如果主引擎已经启动，则 fork 一个引擎
    fun startup(
        context: Context,
        readyListener: FlutterEngineReadyListener? = null
    ): FlutterEngine {
        if (isRunning) { // 正在启动引擎中，抛出异常
            throw UnsupportedOperationException("There is an engine starting and cannot continue")
        }
        isRunning = true
        // 主引擎存在，且还没有使用
        if (mainEngine?.pageId == NAVIGATION_ROUTE_PAGE_ID_NONE) {
            readyListener?.onReady(mainEngine!!)
            currentEngine = mainEngine
            isRunning = false
            return mainEngine!!
        }
        val flutterEngine =
            mainEngine?.engine?.fork(context, entrypoint, null, null)
                ?: ThrioFlutterEngine(context)
        currentEngine =
            FlutterEngine(
                entrypoint,
                flutterEngine,
                mainEngine == null,
                object : FlutterEngineReadyListener {
                    override fun onReady(engine: FlutterEngine) {
                        isRunning = false
                        readyListener?.onReady(engine)
                    }
                })
        mainEngine = mainEngine ?: currentEngine
        return mainEngine!!
    }
}