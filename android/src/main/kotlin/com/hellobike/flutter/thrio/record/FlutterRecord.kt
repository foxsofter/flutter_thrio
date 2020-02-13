package com.hellobike.flutter.thrio.record

import android.util.ArrayMap
import android.util.Log
import com.hellobike.flutter.thrio.data.Record
import java.util.*

object FlutterRecord {

    private val lastIndexes by lazy { ArrayMap<String, Int>() }
    private val stack by lazy { ArrayList<Record>() }

    fun push(url: String): Record {
        val lastIndex = lastIndexes[url] ?: -1
        val record = Record(url, lastIndex + 1)
        lastIndexes[url] = record.index
        stack.add(record)
        Log.e("Thrio", "push url ${record.url} index ${record.index}")
        return record
    }

    fun pop(): Record {
        val record = stack.last()
        Log.e("Thrio", "pop url ${record.url} index ${record.index}")
        lastIndexes[record.url] = record.index - 1
        stack.remove(record)
        return record
    }

    fun popTo(url: String, index: Int): Record {
        val lastIndex = lastIndexes[url] ?: throw IllegalArgumentException("must push url first.")
        require(lastIndex >= index) { "index must be less than lastIndex" }
        while (true) {
            require(stack.isNotEmpty()) { "stack is empty,no match url and index" }
            val record = stack.last()
            if (url == record.url && index >= record.index) {
                return record
            }
            pop()
        }
    }

    fun lastIndex(url: String): Int {
        return lastIndexes[url] ?: -1
    }
}