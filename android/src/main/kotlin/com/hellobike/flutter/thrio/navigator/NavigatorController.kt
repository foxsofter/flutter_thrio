package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.hellobike.flutter.thrio.OnActionListener
import com.hellobike.thrio.OnNotifyListener
import com.hellobike.thrio.Result
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

internal object NavigatorController {
    const val THRIO_ENGINE_ID = "__thrio__"

    private const val KEY_THRIO_STACK_ID = "KEY_THRIO_STACK_ID"
    private const val THRIO_STACK_ID_NONE = -1L

    private const val KEY_THRIO_PUSH_URL = "KEY_THRIO_PUSH_URL"
    private const val THRIO_STACK_INDEX_AUTO = 0
    private const val KEY_THRIO_PUSH_PARAMS = "KEY_THRIO_PUSH_PARAMS"

    private const val KEY_THRIO_PUSH_ANIM = "KEY_THRIO_PUSH_ANIM"
    private const val THRIO_PUSH_ANIM_NORMAL = true


    var action = Action.NONE
    private var record: NavigatorPageRoute? = null
    private var result: Result? = null

    fun hasKey(activity: Activity): Boolean {
        val key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        return key != THRIO_STACK_ID_NONE
    }

    fun getKey(activity: Activity): Long {
        val key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        require(key != THRIO_STACK_ID_NONE) { "didn't found key in this activity $activity" }
        return key
    }

    fun push(context: Context, url: String, params: Map<String, Any>,
             animated: Boolean, result: Result) {
        val builder = NavigatorBuilder.getNavigationBuilder(url)
        val intent = builder.buildIntent(context).apply {
            setClass(context, builder.getActivityClz(url))
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            if (!animated) {
                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            }
            putExtra(KEY_THRIO_PUSH_ANIM, animated)
            putExtra(KEY_THRIO_PUSH_URL, url)
            putExtra(KEY_THRIO_PUSH_PARAMS, HashMap<String, Any>(params))
        }
        builder.navigation(context, intent, params)
        action = Action.PUSH
        this.result = result
    }

    fun didPush(activity: Activity) {
        val result = result
        checkNotNull(result) { "result must not be null" }
        val url = activity.intent.getStringExtra(KEY_THRIO_PUSH_URL) ?: return
        activity.intent.removeExtra(KEY_THRIO_PUSH_URL)

        val params = activity.intent.getSerializableExtra(KEY_THRIO_PUSH_PARAMS).let {
            checkNotNull(it) { "push params not found" }
            it as Map<String, Any>
        }
        activity.intent.removeExtra(KEY_THRIO_PUSH_PARAMS)

        val animated = activity.intent.getBooleanExtra(KEY_THRIO_PUSH_ANIM, THRIO_PUSH_ANIM_NORMAL)
        activity.intent.removeExtra(KEY_THRIO_PUSH_ANIM)

        var key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        if (key == THRIO_STACK_ID_NONE) {
            key = NavigatorPageRouteStack.addKey()
            activity.intent.putExtra(KEY_THRIO_STACK_ID, key)
        }

        action = Action.NONE
        this.result = null

        val record = NavigatorPageRouteStack.push(key, url, activity::class.java)
        record.params = params
        record.animated = animated
        onPush(activity, record) {
            if (!it) {
                NavigatorPageRouteStack.pop(record)
                activity.finish()
            }
            result(it)
        }
    }

    private fun onPush(activity: Activity, record: NavigatorPageRoute, result: Result) {
        if (activity is OnActionListener) {
            activity.onPush(record.url, record.index, record.params, record.animated, result)
            return
        }
        result(true)
    }

    fun pop(context: Context, animated: Boolean, result: Result) {
        if (!NavigatorPageRouteStack.hasRecord()) {
            result(false)
            return
        }
        val record = NavigatorPageRouteStack.last()
        if (record.popDisabled) {
            result(false)
            return
        }
        record.animated = animated
        val intent = Intent(context, record.clazz)
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        context.startActivity(intent)
        action = Action.POP
        this.result = result
    }

    fun didPop(activity: Activity) {
        val result = result
        checkNotNull(result) { "result must not be null" }
        check(NavigatorPageRouteStack.hasRecord()) { "must has record to pop" }
        val record = NavigatorPageRouteStack.last()
        check(record.clazz == activity::class.java) {
            "activity is not match record ${record.clazz}"
        }
        action = Action.NONE
        this.result = null
        onPop(activity, record) {
            if (it) {
                NavigatorPageRouteStack.pop(record)
                didRemoveAndNotify(activity)
            }
            result(it)
        }
    }

    private fun onPop(activity: Activity, record: NavigatorPageRoute, result: Result) {
        if (activity is OnActionListener) {
            activity.onPop(record.url, record.index, record.animated, result)
            return
        }
        result(true)
    }

    fun remove(context: Context, url: String, index: Int, animated: Boolean, result: Result) {
        if (index < 0 || !NavigatorPageRouteStack.hasRecord(url, index)) {
            Log.e("Thrio", "action remove no record url $url index $index")
            result(false)
            return
        }
        val targetIndex = when (index) {
            THRIO_STACK_INDEX_AUTO -> NavigatorPageRouteStack.lastIndex(url)
            else -> index
        }
        val last = NavigatorPageRouteStack.last()
        val record = NavigatorPageRouteStack.last(url, targetIndex)
        if (last == record) {
            Log.e("Thrio", "action remove top record url ${record.url} index ${record.index}")
            result(true)
            return
        }
        Log.e("Thrio", "action remove url ${record.url} index ${record.index}")
        record.removed = true
        result(true)
    }

    fun didRemoveAndNotify(activity: Activity) {
        if (!hasKey(activity)) {
            return
        }
        val key = getKey(activity)
        if (!NavigatorPageRouteStack.hasRecord(key)) {
            Log.e("Thrio", "action didRemoveAndNotify activity $activity finish")
            activity.finish()
            return
        }
        val record = NavigatorPageRouteStack.last(key)
        if (!record.removed) {
            Log.e("Thrio", "action didRemoveAndNotify activity $activity notify last")
            record.removeNotify().onEach {
                if (activity is OnNotifyListener) {
                    activity.onNotify(record.url, record.index, it.key, it.value)
                }
            }
            return
        }
        NavigatorPageRouteStack.pop(record)
        Log.e("Thrio", "action didRemoveAndNotify activity $activity remove pop")
        didRemoveAndNotify(activity)
//                if (activity is OnActionListener) {
//                    activity.onRemove(record.url, record.index, false) {}
//                }
    }

    fun popTo(context: Context, url: String, index: Int, animated: Boolean, result: Result) {
        if (index < 0 || !NavigatorPageRouteStack.hasRecord(url, index)) {
            result(false)
            return
        }
        val targetIndex = when (index) {
            THRIO_STACK_INDEX_AUTO -> NavigatorPageRouteStack.lastIndex(url)
            else -> index
        }
        val record = NavigatorPageRouteStack.last(url, targetIndex)
        // 不能popTo 已经remove的记录
        if (record.removed) {
            result(false)
            return
        }
        record.animated = animated
        val intent = Intent(context, record.clazz)
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        context.startActivity(intent)
        action = Action.POP_TO
        this.record = record
        this.result = result
    }

    fun didPopTo(activity: Activity) {
        val result = result
        checkNotNull(result) { "result must not be null" }
        val record = record
        checkNotNull(record) { "popTo record not found" }
        if (record.clazz != activity::class.java) {
            return
        }
        val key = getKey(activity)
        if (NavigatorPageRouteStack.getKey(record) != key) {
            activity.finish()
            popTo(activity, record.url, record.index, record.animated, result)
            return
        }
        action = Action.NONE
        this.record = null
        this.result = null
        onPopTo(activity, record) {
            if (it) {
                NavigatorPageRouteStack.popTo(record)
                didRemoveAndNotify(activity)
            }
            result(it)
        }
    }

    private fun onPopTo(activity: Activity, record: NavigatorPageRoute, result: Result) {
        if (activity is OnActionListener) {
            activity.onPopTo(record.url, record.index, record.animated, result)
            return
        }
        result(true)
    }

    fun clearStack(activity: Activity) {
        if (!hasKey(activity)) {
            return
        }
        val key = getKey(activity)
        if (!NavigatorPageRouteStack.hasRecord(key)) {
            return
        }
        val record = NavigatorPageRouteStack.first(key)
        if (activity is OnActionListener) {
            activity.onPopTo(record.url, record.index, false) { }
            activity.onPop(record.url, record.index, false) { }
        }
        NavigatorPageRouteStack.pop(key)
    }

    fun notify(url: String, index: Int, name: String, params: Map<String, Any>, result: Result) {
        if (index < 0 || !NavigatorPageRouteStack.hasRecord(url)) {
            result(false)
            return
        }
        val targetIndex = when (index) {
            THRIO_STACK_INDEX_AUTO -> NavigatorPageRouteStack.lastIndex(url)
            else -> index
        }
        val record = NavigatorPageRouteStack.last(url, targetIndex)
        record.addNotify(name, params)
        result(true)
    }

    fun setPopDisabled(url: String, index: Int, disable: Boolean, result: Result) {
        if (index < 0 || !NavigatorPageRouteStack.hasRecord(url)) {
            result(false)
            return
        }
        val targetIndex = when (index) {
            THRIO_STACK_INDEX_AUTO -> NavigatorPageRouteStack.lastIndex(url)
            else -> index
        }
        val record = NavigatorPageRouteStack.last(url, targetIndex)
        record.popDisabled = disable
        result(true)
    }

    fun init(context: Context) {
        val engine = FlutterEngine(context).apply {
            dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        }
        FlutterEngineCache.getInstance().put(THRIO_ENGINE_ID, engine)
    }


    fun backUpData(activity: Activity, data: Bundle?) {
        if (data == null) {
            return
        }
        if (!hasKey(activity)) {
            return
        }
        val key = getKey(activity)
        data.putLong(KEY_THRIO_STACK_ID, key)
    }

    fun restoreData(activity: Activity, data: Bundle?) {
        if (data == null) {
            return
        }
        val key = data.getLong(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        if (key == THRIO_STACK_ID_NONE) {
            return
        }
        activity.intent.putExtra(KEY_THRIO_STACK_ID, key)

    }
}
