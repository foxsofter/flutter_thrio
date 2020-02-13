package com.hellobike.flutter.thrio.navigator

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.hellobike.flutter.thrio.channel.ChannelManager
import com.hellobike.flutter.thrio.data.Record
import com.hellobike.flutter.thrio.record.FlutterRecord
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger

open class ThrioActivity : FlutterActivity() {
    companion object {

        private const val KEY_THRIO_ACTION = "KEY_THRIO_ACTION"
        private const val KEY_THRIO_STACK = "KEY_THRIO_STACK"
        private const val KEY_THRIO_URL = "KEY_THRIO_URL"
        private const val KEY_THRIO_INDEX = "KEY_THRIO_INDEX"

        private const val KEY_THRIO_ACTION_PUSH = "push"
        private const val KEY_THRIO_ACTION_POP = "pop"
        private const val KEY_THRIO_ACTION_POP_TO = "popTo"

        internal fun push(context: Context, url: String) {
            val intent = build(context).apply {
                putExtra(KEY_THRIO_ACTION, KEY_THRIO_ACTION_PUSH)
                putExtra(KEY_THRIO_URL, url)
            }
            context.startActivity(intent)
        }

        internal fun pop(context: Context) {
            val intent = build(context).apply {
                putExtra(KEY_THRIO_ACTION, KEY_THRIO_ACTION_POP)
            }
            context.startActivity(intent)
        }

        internal fun popTo(context: Context, url: String, index: Int) {
            val intent = build(context).apply {
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra(KEY_THRIO_ACTION, KEY_THRIO_ACTION_POP_TO)
                putExtra(KEY_THRIO_URL, url)
                putExtra(KEY_THRIO_INDEX, index)
            }
            context.startActivity(intent)
        }

        private fun build(context: Context): Intent {
            return Intent(context, ThrioActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
//                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                // 取消动画
//                addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
            }
        }

    }

    private val flutterStack by lazy { ArrayList<Record>() }

    private val channel by lazy {
        val messenger: BinaryMessenger = flutterEngine?.dartExecutor
                ?: throw IllegalArgumentException("flutterEngine does not exist")
        ChannelManager.get(messenger.hashCode())
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val saveStack = savedInstanceState?.getParcelableArrayList<Record>(KEY_THRIO_STACK)
        if (saveStack == null) {
            firstPushAction(intent)
        } else {
            flutterStack.addAll(saveStack)
        }

        window.decorView.postDelayed({
            showLastRecord()
        }, 1000)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        when (intent.getStringExtra(KEY_THRIO_ACTION) ?: return) {
            KEY_THRIO_ACTION_PUSH -> onPushAction(intent)
            KEY_THRIO_ACTION_POP -> onPopAction(intent)
            KEY_THRIO_ACTION_POP_TO -> onPopToAction(intent)
            else -> return
        }
    }

    override fun onBackPressed() {
        if (flutterStack.isNotEmpty()) {
            didPop()
            return
        }
        super.onBackPressed()
    }

    private fun firstPushAction(intent: Intent) {
        val url = intent.getStringExtra(KEY_THRIO_URL)
                ?: throw IllegalArgumentException("url not found in intent")
        didPush(url)
    }

    private fun onPushAction(intent: Intent) {
        val url = intent.getStringExtra(KEY_THRIO_URL)
                ?: throw IllegalArgumentException("url not found in intent")
        didPush(url)
        showLastRecord()
    }

    private fun onPopAction(intent: Intent) {
        didPop()
    }

    private fun onPopToAction(intent: Intent) {
        val url = intent.getStringExtra(KEY_THRIO_URL) ?: return
        val index = intent.getIntExtra(KEY_THRIO_INDEX, -1)
        if (index == -1) {
            return
        }
        didPopTo(url, index)
    }

    private fun showLastRecord() {
        val record = flutterStack.last()
        channel.onPush(record)
    }

    private fun didPush(url: String) {
        val record = FlutterRecord.push(url)
        flutterStack.add(record)
    }


    private fun didPop() {
        val stack = flutterStack
        val record = stack.last()
        stack.remove(record)
        FlutterRecord.pop()
        channel.onPop(record)
        if (stack.isEmpty()) {
            finish()
        }
    }

    private fun didPopTo(url: String, index: Int) {
        val stack = flutterStack
        while (true) {
            val record = stack.last()
            if (record.url == url && record.index <= index) {
                FlutterRecord.popTo(record.url, record.index)
                Log.e("Thrio", "channel popTo url ${record.url} index ${record.index}")
                channel.onPopTo(record)
                break
            }
            stack.remove(record)
            /*
               当前Activity无对应页面，pop到上个FlutterActivity
               使用 FLAG_ACTIVITY_CLEAR_TOP
             */
            if (stack.isEmpty()) {
                channel.onPopTo(record)
                finish()
                popTo(context, url, index)
                break
            }
        }


    }

    internal fun popAll() {
        val stack = flutterStack
        if (stack.isEmpty()) {
            return
        }
        val first = stack.first()
        didPopTo(first.url, first.index)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putParcelableArrayList(KEY_THRIO_STACK, flutterStack)
    }

}