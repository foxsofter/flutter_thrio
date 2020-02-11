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

        private val KEY_THRIO_ACTION = "KEY_THRIO_ACTION"
        private val KEY_THRIO_STACK = "KEY_THRIO_STACK"
        private val KEY_THRIO_URL = "KEY_THRIO_URL"
        private val KEY_THRIO_INDEX = "KEY_THRIO_INDEX"

        private val KEY_THRIO_ACTION_PUSH = "push"
        private val KEY_THRIO_ACTION_POP = "pop"
        private val KEY_THRIO_ACTION_POP_TO = "popTo"

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
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
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
        Log.e("Thrio", "new page")
        super.onCreate(savedInstanceState)
        val saveStack = savedInstanceState?.getParcelableArrayList<Record>(KEY_THRIO_STACK)
        if (saveStack == null) {
            initPushAction(intent)
        } else {
            flutterStack.addAll(saveStack)
        }

        window.decorView.postDelayed({
            showTopRecord()
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
            pop()
            return
        }
        super.onBackPressed()
    }

    private fun initPushAction(intent: Intent) {
        val url = intent.getStringExtra(KEY_THRIO_URL)
                ?: throw IllegalArgumentException("url not found in intent")
        val record = FlutterRecord.build(url)
        flutterStack.add(record)
        Log.e("Thrio", "push url ${record.url} index ${record.index}")
    }

    private fun onPushAction(intent: Intent) {
        initPushAction(intent)
        showTopRecord()
    }

    private fun onPopAction(intent: Intent) {
        pop()
    }

    private fun onPopToAction(intent: Intent) {
        val url = intent.getStringExtra(KEY_THRIO_URL) ?: return
        val index = intent.getIntExtra(KEY_THRIO_INDEX, -1)
        if (index == -1) {
            return
        }
        popTo(url, index)
    }

    private fun pop() {
        val record = flutterStack.removeAt(flutterStack.lastIndex)
        FlutterRecord.pop(record.url)
        channel.onPop(record)
        if (flutterStack.isEmpty()) {
            finish()
        }
        Log.e("Thrio", "pop url ${record.url} index ${record.index}")
    }

    private fun popTo(url: String, index: Int) {
        while (true) {
            if (flutterStack.isEmpty()) {
                Log.e("Thrio", "page url $url index $index not found")
                popTo(context, url, index)
                break
            }
            val record = flutterStack.last()
            if (record.url == url && record.index == index) {
                break
            }
            pop()
        }
    }

    private fun showTopRecord() {
        val record = flutterStack.last()
        channel.onPush(record)
        Log.e("Thrio", "show url ${record.url} index ${record.index}")
    }


    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putParcelableArrayList(KEY_THRIO_STACK, flutterStack)
    }
}