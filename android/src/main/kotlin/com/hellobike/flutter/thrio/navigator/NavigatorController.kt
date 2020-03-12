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
import android.util.Log
import com.hellobike.flutter.thrio.*
import com.hellobike.flutter.thrio.OnActionListener

internal object NavigatorController {

    private const val KEY_THRIO_STACK_ID = "KEY_THRIO_STACK_ID"
    private const val THRIO_STACK_ID_NONE = -1L

    private const val THRIO_STACK_INDEX_AUTO = 0

    private const val KEY_THRIO_PUSH_DATA = "KEY_THRIO_PUSH_ANIM"

    var action = Action.NONE

    fun hasKey(activity: Activity): Boolean {
        val key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        return key != THRIO_STACK_ID_NONE
    }

    fun getKey(activity: Activity): Long {
        val key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
        require(key != THRIO_STACK_ID_NONE) { "didn't found key in this activity $activity" }
        return key
    }

    object Push {

        private var result: PushResult? = null

        fun push(context: Context,
                 url: String, params: Any? = null, animated: Boolean,
                 result: PushResult) {
            if (action != Action.NONE) {
                result(null)
                return
            }
            val builder = NavigatorBuilder.getNavigationBuilder(url)
            val intent = builder.buildIntent(context).apply {
                setClass(context, builder.getActivityClz(url))
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                if (!animated) {
                    addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
                }
                val data = HashMap<String, Any>()
                data["url"] = url
                if (params != null) {
                    data["params"] = params
                }
                data["animated"] = animated
                putExtra(KEY_THRIO_PUSH_DATA, data)
            }
            builder.navigation(context, intent, params)
            action = Action.PUSH
            this.result = result
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

            var key = activity.intent.getLongExtra(KEY_THRIO_STACK_ID, THRIO_STACK_ID_NONE)
            if (key == THRIO_STACK_ID_NONE) {
                key = NavigatorPageRouteStack.addKey()
                activity.intent.putExtra(KEY_THRIO_STACK_ID, key)
            }
            val record = NavigatorPageRouteStack.push(key, url, activity::class.java)
            record.params = params
            record.animated = animated
            onPush(activity, record) {
                if (!it) {
                    NavigatorPageRouteStack.pop(record)
                    activity.finish()
                }
                result(record.index)
                action = Action.NONE
                this.result = null
            }
        }

        private fun onPush(activity: Activity, record: NavigatorPageRoute, result: Result) {
            if (activity is OnActionListener) {
                activity.onPush(record.url, record.index, record.params, record.animated, result)
                return
            }
            result(true)
        }

    }

    object Pop {

        private var result: Result? = null

        fun pop(context: Context, animated: Boolean, result: Result) {
            if (action != Action.NONE) {
                result(false)
                return
            }
            if (!NavigatorPageRouteStack.hasRecord()) {
                result(false)
                return
            }
            val record = NavigatorPageRouteStack.last()
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
            onPop(activity, record) {
                if (it) {
                    NavigatorPageRouteStack.pop(record)
                    val key = getKey(activity)
                    if (!NavigatorPageRouteStack.hasRecord(key)) {
                        activity.finish()
                    } else {
                        removeOrNotify(activity)
                    }
                }
                result(it)
                action = Action.NONE
                this.result = null
            }
        }

        private fun onPop(activity: Activity, record: NavigatorPageRoute, result: Result) {
            if (activity is OnActionListener) {
                activity.onPop(record.url, record.index, record.animated, result)
                return
            }
            result(true)
        }
    }

    object PopTo {

        private var result: Result? = null
        private var record: NavigatorPageRoute? = null

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
//                didRemoveAndNotify(activity)
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

    }

    object Remove {

        private var result: Result? = null
        private var record: NavigatorPageRoute? = null

        fun remove(context: Context, url: String, index: Int, animated: Boolean, result: Result) {
            if (action != Action.NONE) {
                result(false)
                return
            }
            if (index < 0 || !NavigatorPageRouteStack.hasRecord(url, index)) {
                Log.e("Thrio", "action remove no record url $url index $index")
                result(false)
                return
            }
            val targetIndex = when (index) {
                THRIO_STACK_INDEX_AUTO -> NavigatorPageRouteStack.lastIndex(url)
                else -> index
            }
            if (!NavigatorPageRouteStack.hasRecord()) {
                result(false)
                return
            }
            val record = NavigatorPageRouteStack.last(url, targetIndex)
            val last = NavigatorPageRouteStack.last()
            if (last == record) {
                record.animated = animated
            }
            val intent = Intent(context, last.clazz)
            intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            context.startActivity(intent)
            action = Action.REMOVE
            this.record = record
            this.result = result
        }

        fun didRemove(activity: Activity) {
            val result = result
            checkNotNull(result) { "result must not be null" }
            val record = record
            checkNotNull(record) { "remove record not found" }
            check(NavigatorPageRouteStack.hasRecord()) { "must has record" }
            val last = NavigatorPageRouteStack.last()
            check(last.clazz == activity::class.java) {
                "activity is not match record ${record.clazz}"
            }
            action = Action.NONE
            this.record = null
            this.result = null
            if (last == record) {
                NavigatorPageRouteStack.pop(record)
                onRemove(activity, record, result)
                return
            }
            record.removed = true
            result(true)
            return
        }

        private fun onRemove(activity: Activity, record: NavigatorPageRoute, result: Result) {
            if (activity is OnActionListener) {
                activity.onRemove(record.url, record.index, record.animated, result)
                return
            }
            result(true)
        }
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

    fun removeOrNotify(activity: Activity) {
        if (!hasKey(activity)) {
            return
        }
        val key = getKey(activity)
        check(NavigatorPageRouteStack.hasRecord(key)) { "must has record to remove or notify" }
        val record = NavigatorPageRouteStack.last(key)
        if (record.removed) {
            Log.e("Thrio", "action didRemove activity $activity")
            NavigatorPageRouteStack.pop(record)
            if (activity is OnActionListener) {
                activity.onRemove(record.url, record.index, false) {}
            }
            if (NavigatorPageRouteStack.hasRecord(key)) {
                removeOrNotify(activity)
                return
            }
            activity.finish()
            return
        }
        Log.e("Thrio", "action didRemoveAndNotify activity $activity notify last")
        record.removeNotify().onEach {
            if (activity is OnActionListener) {
                activity.onNotify(record.url, record.index, it.key, it.value)
                return@onEach
            }
            if (activity is OnNotifyListener) {
                activity.onNotify(it.key, it.value)
            }
        }
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

//
//        private val pushing = mutableMapOf<String, NavigatorPageRoute>()
//        private val results = mutableMapOf<String, IntResult>()
//
//        private fun canPush(url: String): Boolean {
//            if (action != Action.NONE) {
//                return false
//            }
//            if (!NavigatorBuilder.hasNavigationBuilder(url)) {
//                return false
//            }
//            return true
//        }
//
//        fun push(context: Context,
//                 url: String, params: Map<String, Any>, animated: Boolean,
//                 result: IntResult) {
//            if (!canPush(url)) {
//                result(null)
//                return
//            }
//            action = Action.PUSH
//            val builder = NavigatorBuilder.getNavigationBuilder(url)
//            val record = NavigatorPageRoute(url, 0, builder.getActivityClz(url)).apply {
//                this.params = params
//                this.animated = animated
//            }
//            if (NavigatorBuilder.hasNativeNavigationBuilder(url)) {
//                val result = nativePush(context, record, builder)
//                return
//            }
//            if (true) {
//                val result = flutterPush(context, record, builder, result)
//            }
//        }
//
//        private fun nativePush(context: Context,
//                               record: NavigatorPageRoute, builder: NavigationBuilder) {
//            val intent = builder.buildIntent(context).apply {
//                setClass(context, builder.getActivityClz(record.url))
//                if (!record.animated) {
//                    addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
//                }
//            }
//            builder.navigation(context, intent, record.params)
//            action = Action.NONE
//        }
//
//        private fun flutterPush(context: Context,
//                                record: NavigatorPageRoute, builder: NavigationBuilder,
//                                result: IntResult) {
//
//            val engine = NavigatorFlutterEngineFactory.getNavigatorFlutterEngine()
//            if (engine == null) {
//                result(null)
//                return
//            }
////            engine.sendChannel.onPush(record.url,record.)
////            pushing["$url###${0}"] = record
////            results["$url###${0}"] = result
//        }
//    }

}
