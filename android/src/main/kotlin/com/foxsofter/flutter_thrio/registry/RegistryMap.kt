/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 Hellobike Group
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

package com.foxsofter.flutter_thrio.registry

import com.foxsofter.flutter_thrio.VoidCallback

class RegistryMap<K, V> : Iterable<Map.Entry<K, V>> {
    private val maps by lazy { mutableMapOf<K, V>() }

    fun registry(key: K, value: V): VoidCallback {
        maps[key] = value
        return { maps.remove(key) }
    }

    fun registryAll(values: Map<K, V>): VoidCallback {
        maps.putAll(values)
        return { values.keys.forEach { maps.remove(it) } }
    }

    fun clear() = maps.clear()

    operator fun get(key: K): V? = maps[key]

    override fun iterator(): Iterator<Map.Entry<K, V>> = maps.iterator()
}