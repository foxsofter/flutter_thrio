package com.hellobike.flutter.thrio.record

import android.app.Activity
import android.util.ArrayMap
import com.hellobike.flutter.thrio.data.Record
import java.util.*

object FlutterRecord {
    private val KEY_FLUTTER_STACK = "KEY_FLUTTER_STACK"

    private val pageStack by lazy { Stack<Record>() }
    private val pageLastIndex by lazy { ArrayMap<String, Int>() }


    fun pushRecord(url: String, activity: Activity): Record {
        val index = pageLastIndex.getOrDefault(url, -1)
        val record = Record(url, index + 1)
        pageStack.push(record)
        pageLastIndex[url] = record.index
        return record
    }

    fun popRecord(activity: Activity): Record {
        val record = pageStack.pop()
        pageLastIndex[record.url] = record.index - 1
        return record
    }
}