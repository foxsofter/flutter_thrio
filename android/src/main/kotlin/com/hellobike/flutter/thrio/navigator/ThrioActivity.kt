package com.hellobike.flutter.thrio.navigator

import android.content.Context
import android.content.Intent
import android.os.Bundle
import com.hellobike.flutter.thrio.app.ThrioApp
import com.hellobike.flutter.thrio.data.Record
import com.hellobike.flutter.thrio.record.FlutterRecord
import io.flutter.embedding.android.FlutterActivity
import java.util.*

open class ThrioActivity : FlutterActivity() {
    companion object {

        private val KEY_THRIO_ACTION = "KEY_THRIO_ACTION"
        private val KEY_THRIO_STACK = "KEY_THRIO_STACK"
        private val KEY_THRIO_URL = "KEY_THRIO_URL"

        private val KEY_THRIO_ACTION_PUSH = "push"
        private val KEY_THRIO_ACTION_POP = "pop"

        fun push(context: Context, url: String) {
            val intent = build(context).apply {
                putExtra(KEY_THRIO_ACTION, KEY_THRIO_ACTION_PUSH)
                putExtra(KEY_THRIO_URL, url)
            }
            context.startActivity(intent)
        }

        fun pop(context: Context) {
            val intent = build(context).apply {
                putExtra(KEY_THRIO_ACTION, KEY_THRIO_ACTION_POP)
            }
            context.startActivity(intent)
        }

        private fun build(context: Context): Intent {
            return Intent(context, ThrioActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
        }

    }

    private val flutterStack by lazy { Stack<Record>() }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.decorView.postDelayed({
            onIntent(intent)
        }, 1000)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        onIntent(intent)
    }

    private fun onIntent(intent: Intent) {
        val action = intent.getStringExtra(KEY_THRIO_ACTION) ?: return
        when (action) {
            KEY_THRIO_ACTION_PUSH -> {
                val url = intent.getStringExtra(KEY_THRIO_URL) ?: return
                push(url)
            }
            KEY_THRIO_ACTION_POP -> pop()
            else -> return
        }
    }

    private fun push(url: String) {
        val record = FlutterRecord.build(url)
        flutterStack.push(record)
        ThrioApp.onPush(record)
    }

    private fun pop() {
        val record = flutterStack.pop()
        if (flutterStack.isEmpty()) {
            finish()
        }
        FlutterRecord.pop(record.url)
        ThrioApp.onPop(record)
    }

}