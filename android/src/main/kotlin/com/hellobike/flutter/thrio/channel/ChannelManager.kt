package com.hellobike.flutter.thrio.channel

import android.util.ArrayMap

internal object ChannelManager {
    private val channels = ArrayMap<Int, ThrioChannel>()

    fun cache(tag: Int, channel: ThrioChannel) {
        channels[tag] = channel
    }

    fun get(tag: Int): ThrioChannel {
        return channels[tag] ?: throw IllegalArgumentException("no channel with this tag")
    }

    fun remove(tag: Int) {
        channels.remove(tag)
    }

}