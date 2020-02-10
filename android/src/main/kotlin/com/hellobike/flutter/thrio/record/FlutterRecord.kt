package com.hellobike.flutter.thrio.record

import android.util.ArrayMap
import com.hellobike.flutter.thrio.data.Record

object FlutterRecord {

    private val pageLastIndex by lazy { ArrayMap<String, Int>() }

    fun build(url: String): Record {
        val lastIndex = pageLastIndex[url] ?: -1
        val record = Record(url, lastIndex + 1)
        pageLastIndex[url] = record.index
        return record
    }

    fun pop(url: String) {
        val lastIndex = pageLastIndex[url] ?: return
        pageLastIndex[url] = lastIndex - 1
    }
}