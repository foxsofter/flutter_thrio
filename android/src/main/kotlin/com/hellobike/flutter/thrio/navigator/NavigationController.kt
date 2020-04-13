// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

package com.hellobike.flutter.thrio.navigator

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.support.annotation.UiThread
import android.util.Log
import com.hellobike.flutter.thrio.OnNotifyListener
import com.hellobike.flutter.thrio.PoppedResult
import com.hellobike.flutter.thrio.PushResult
import com.hellobike.flutter.thrio.Result
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory.THRIO_ENGINE_FLUTTER_ID
import com.hellobike.flutter.thrio.navigator.FlutterEngineFactory.THRIO_ENGINE_NATIVE_ID
import io.flutter.embedding.android.ThrioActivity
import java.lang.ref.WeakReference

internal object NavigationController {

    private const val KEY_THRIO_STACK_ID = "KEY_THRIO_STACK_ID"
    private const val THRIO_STACK_ID_NONE = -1L

    private const val THRIO_STACK_INDEX_AUTO = 0

    private const val KEY_THRIO_PUSH_DATA = "KEY_THRIO_PUSH_DATA"

    var action = RouteAction.NONE

    fun hasKey(activity: Activity): Boolean {
        val key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        return key != THRIO_STACK_ID_NONE
    }

    fun getKey(activity: Activity): Long {
        val key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        require(key != THRIO_STACK_ID_NONE) { "didn't found key in this activity $activity" }
        return key
    }

    object Navigator {

        @UiThread
        fun pop(context: Context, params: Any? = null, animated: Boolean, result: Result = {}) {
            if (action != RouteAction.NONE) {
                result(false)
                return
            }
            if (!PageRouteStack.hasRoute()) {
                result(false)
                return
            }
            action = RouteAction.POP
            val record = PageRouteStack.last()
            record.resultParams = params
            record.animated = animated
            onPop(record) {
                action = RouteAction.NONE
                result(it)
                if (!it) {
                    // Flutter WillPopScope is false
                    return@onPop
                }
                record.poppedResult?.get()?.let { it(record.resultParams) }
                PageRouteStack.pop(record)
                val intent = Intent(context, record.clazz)
                intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                context.startActivity(intent)
            }
        }

        private fun onPop(record: PageRoute, result: Result) {
            val entryPoint = record.entryPoint
                    ?: throw IllegalStateException("record $record must have current engineId, current is null")
            if (entryPoint == THRIO_ENGINE_NATIVE_ID) {
                result(true)
                return
            }
            FlutterEngineFactory.getEngine(entryPoint)?.onPop(record, result)
                    ?: throw IllegalStateException("current engine must not be null")
            val parentEntryPoint = record.parentEntryPoint
                    ?: throw IllegalStateException("record $record must have from engineId, current is null")
            if (entryPoint == parentEntryPoint || parentEntryPoint == THRIO_ENGINE_NATIVE_ID) {
                return
            }
            FlutterEngineFactory.getEngine(parentEntryPoint)?.onPop(record) {}
                    ?: throw IllegalStateException("from engine must not be null")
        }
    }

    object Push {

        private var result: PushResult? = null
        private var poppedResult: PoppedResult? = null

        fun push(context: Context,
                 url: String, params: Any? = null, animated: Boolean,
                 from: String, poppedResult: PoppedResult? = null,
                 result: PushResult) {
            if (action != RouteAction.NONE) {
                result(null)
                return
            }
            val builder = PageBuilders.getPageBuilder(url)
            val intent = builder.buildIntent(context).apply {
                setClass(context, builder.getActivityClz(url))
                if (!animated) {
                    addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                }
                val data = HashMap<String, Any>()
                data["url"] = url
                if (params != null) {
                    data["params"] = params
                }
                data["animated"] = animated
                if (PageBuilders.isFlutterPageBuilder(builder)) {
                    data["entryPoint"] = THRIO_ENGINE_FLUTTER_ID
                } else {
                    data["entryPoint"] = THRIO_ENGINE_NATIVE_ID
                }
                data["parentEntryPoint"] = from
                putExtra(KEY_THRIO_PUSH_DATA, data)
            }
            builder.navigation(context, intent, params)
            action = RouteAction.PUSH
            this.result = result
            this.poppedResult = poppedResult
        }

        fun didPush(activity: Activity) {
            val result = result
            checkNotNull(result) { "result must not be null" }
            val data = activity.intent.getSerializableExtra(KEY_THRIO_PUSH_DATA).let {
                checkNotNull(it) { "push params not found" }
                it as Map<String, Any>
            }
            activity.intent.removeExtra(KEY_THRIO_PUSH_DATA)
            val url = data["url"] as String
            val animated = data["animated"] as Boolean
            val params = data["params"]
            val entryPoint = data["entryPoint"] as String
            val parentEntryPoint = data["parentEntryPoint"] as String

            var key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
            if (key == THRIO_STACK_ID_NONE) {
                key = PageRouteStack.pushNewStack()
                activity.intent.putExtra(KEY_THRIO_STACK_ID, key)
            }
            val isFirst = PageRouteStack.hasRoute(getKey(activity))
            val record = PageRouteStack.push(key, url, activity::class.java)
            record.params = params
            record.animated = animated
            val poppedResult = poppedResult
            this.poppedResult = null
            if (poppedResult != null) {
                record.poppedResult = WeakReference(poppedResult)
            }

            record.parentEntryPoint = parentEntryPoint
            record.entryPoint = entryPoint

            onPush(activity, record, isFirst) {
                if (!it) {
                    PageRouteStack.pop(record)
                    activity.finish()
                    result(null)
                } else {
                    result(record.index)
                }
            }
            action = RouteAction.NONE
            this.result = null
        }

        private fun onPush(activity: Activity, record: PageRoute, isNested: Boolean, result: Result) {
            if (activity is ThrioActivity) {
                activity.onPush(record, isNested, result)
                return
            }
            result(true)
        }

    }


    object PopTo {

        private var result: Result? = null
        private var record: PageRoute? = null

        fun popTo(context: Context, url: String, index: Int, animated: Boolean, result: Result) {
            if (index < 0 || !PageRouteStack.hasRoute(url, index)) {
                result(false)
                return
            }
            val targetIndex = when (index) {
                THRIO_STACK_INDEX_AUTO -> PageRouteStack.lastIndex(url)
                else -> index
            }
            val record = PageRouteStack.last(url, targetIndex)
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
            action = RouteAction.POP_TO
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
            if (PageRouteStack.getKey(record) != key) {
                activity.finish()
                popTo(activity, record.url, record.index, record.animated, result)
                return
            }
            action = RouteAction.NONE
            this.record = null
            this.result = null
            onPopTo(activity, record) {
                if (it) {
                    PageRouteStack.popTo(record)
                    didNotify(activity, record)
                }
                result(it)
            }
        }

        private fun onPopTo(activity: Activity, record: PageRoute, result: Result) {
            if (activity is ThrioActivity) {
                activity.onPopTo(record.url, record.index, record.animated, result)
                return
            }
            result(true)
        }
    }

    object Remove {

        private var result: Result? = null
        private var record: PageRoute? = null

        fun remove(context: Context, url: String, index: Int, animated: Boolean, result: Result) {
            if (action != RouteAction.NONE) {
                result(false)
                return
            }
            if (index < 0 || !PageRouteStack.hasRoute(url, index)) {
                Log.e("Thrio", "action remove no record url $url index $index")
                result(false)
                return
            }
            val targetIndex = when (index) {
                THRIO_STACK_INDEX_AUTO -> PageRouteStack.lastIndex(url)
                else -> index
            }
            if (!PageRouteStack.hasRoute()) {
                result(false)
                return
            }
            val record = PageRouteStack.last(url, targetIndex)
            val last = PageRouteStack.last()
            if (last == record) {
                record.animated = animated
            }
            val intent = Intent(context, last.clazz)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            context.startActivity(intent)
            action = RouteAction.REMOVE
            this.record = record
            this.result = result
        }

        fun didRemove(activity: Activity) {
            val result = result
            checkNotNull(result) { "result must not be null" }
            val record = record
            checkNotNull(record) { "remove record not found" }
            check(PageRouteStack.hasRoute()) { "must has record" }
            val last = PageRouteStack.last()
            check(last.clazz == activity::class.java) {
                "activity is not match record ${record.clazz}"
            }
            action = RouteAction.NONE
            this.record = null
            this.result = null
            if (last == record) {
                PageRouteStack.pop(record)
                onRemove(activity, record, result)
                return
            }
            record.removed = true
            result(true)
            return
        }

        private fun onRemove(activity: Activity, record: PageRoute, result: Result) {
            if (activity is ThrioActivity) {
                activity.onRemove(record.url, record.index, record.animated, result)
                return
            }
            result(true)
        }
    }

    fun notify(url: String, index: Int, name: String, params: Any? = null, result: Result) {
        if (index < 0 || !PageRouteStack.hasRoute(url)) {
            result(false)
            return
        }
        val targetIndex = when (index) {
            THRIO_STACK_INDEX_AUTO -> PageRouteStack.lastIndex(url)
            else -> index
        }
        val record = PageRouteStack.last(url, targetIndex)
        record.addNotify(name, params)
        result(true)
    }

    fun removeOrNotify(activity: Activity) {
        if (!hasKey(activity)) {
            return
        }
        val key = getKey(activity)
        if (!PageRouteStack.hasRoute(key)) {
            activity.finish()
            return
        }
        val record = PageRouteStack.last(key)
        if (record.removed) {
            Log.e("Thrio", "page ${record.url} index ${record.index} remove at activity $activity")
            PageRouteStack.pop(record)
            if (activity is ThrioActivity) {
                activity.onRemove(record.url, record.index, false) {}
            }
            if (PageRouteStack.hasRoute(key)) {
                removeOrNotify(activity)
                return
            }
            activity.finish()
            return
        }
        didNotify(activity, record)
    }

    private fun didNotify(activity: Activity, record: PageRoute) {
        record.removeNotify().onEach {
            if (activity is ThrioActivity) {
                Log.e("Thrio", "page ${record.url} index ${record.index} notify")
                activity.onNotify(record.url, record.index, it.key, it.value)
                return@onEach
            }
            if (activity is OnNotifyListener) {
                activity.onNotify(it.key, it.value)
            }
        }
    }

    fun clearStack(activity: Activity) {
//        if (!hasKey(activity)) {
//            return
//        }
//        val key = getKey(activity)
//        if (!NavigatorPageRouteStack.hasRoute(key)) {
//            return
//        }
//        val record = NavigatorPageRouteStack.first(key)
//        if (activity is ThrioActivity) {
//            activity.onPopTo(record.url, record.index, false) { }
//            activity.onPop(record) { }
//        }
//        NavigatorPageRouteStack.popStack(key)
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
