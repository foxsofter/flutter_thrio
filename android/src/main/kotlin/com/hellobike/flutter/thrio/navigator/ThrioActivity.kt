package com.hellobike.flutter.thrio.navigator

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.PersistableBundle
import com.hellobike.flutter.thrio.channel.ChannelManager
import com.hellobike.flutter.thrio.channel.ThrioChannel
import com.hellobike.flutter.thrio.data.Record
import com.hellobike.flutter.thrio.record.FlutterRecord
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.BinaryMessenger
import java.util.*

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

    private lateinit var flutterStack: Stack<Record>

    private val channel by lazy {
        val messenger: BinaryMessenger = flutterEngine?.dartExecutor
                ?: throw IllegalArgumentException("flutterEngine does not exist")
        ChannelManager.get(messenger.hashCode())
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        val saveStack = savedInstanceState?.getSerializable(KEY_THRIO_STACK)
        flutterStack = if (saveStack != null && saveStack is Stack<*>) {
            saveStack as Stack<Record>
        } else {
            Stack()
        }
        super.onCreate(savedInstanceState)
        window.decorView.postDelayed({
            onIntent(intent)
        }, 1000)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        onIntent(intent)
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putSerializable(KEY_THRIO_STACK, flutterStack)
    }

    private fun onIntent(intent: Intent) {
        val action = intent.getStringExtra(KEY_THRIO_ACTION) ?: return
        when (action) {
            KEY_THRIO_ACTION_PUSH -> {
                val url = intent.getStringExtra(KEY_THRIO_URL) ?: return
                push(url)
            }
            KEY_THRIO_ACTION_POP -> pop()
            KEY_THRIO_ACTION_POP_TO -> {
                val url = intent.getStringExtra(KEY_THRIO_URL) ?: return
                val index = intent.getIntExtra(KEY_THRIO_INDEX, -1)
                if (index == -1) {
                    return
                }
                popTo(url, index)
            }
            else -> return
        }
    }

    private fun push(url: String) {
        val record = FlutterRecord.build(url)
        flutterStack.push(record)
        channel.onPush(record)
    }

    private fun pop() {
        val record = flutterStack.pop()
        FlutterRecord.pop(record.url)
        channel.onPop(record)
        if (flutterStack.isEmpty()) {
            finish()
        }
    }

    private fun popTo(url: String, index: Int) {
        while (true) {
            if (flutterStack.isEmpty()) {
                break
            }
            val record = flutterStack.peek()
            if (record.url == url && record.index == index) {
                break
            }
            pop()
        }
    }
}