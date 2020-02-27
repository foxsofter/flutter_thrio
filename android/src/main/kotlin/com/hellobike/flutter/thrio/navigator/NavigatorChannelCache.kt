package com.hellobike.flutter.thrio.navigator

import android.util.ArrayMap


internal object NavigatorChannelCache {

    private val channels = ArrayMap<Int, NavigatorSendChannel>()

    fun cache(tag: Int, channel: NavigatorSendChannel) {
        channels[tag] = channel
    }

    fun get(tag: Int): NavigatorSendChannel {
        return channels[tag] ?: throw IllegalArgumentException("no channel with this tag")
    }

    fun remove(tag: Int) {
        channels.remove(tag)
    }
}