/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2021 foxsofter.
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

package com.foxsofter.flutter_thrio.module

import com.foxsofter.flutter_thrio.exception.ThrioException
import com.foxsofter.flutter_thrio.extension.canTransToFlutter
import com.foxsofter.flutter_thrio.navigator.FlutterEngineFactory

class ModuleContext {
    internal val params by lazy { mutableMapOf<String, Any>() }

    operator fun get(key: String): Any? = params[key]

    operator fun set(key: String, value: Any) {
        var v = params[key]
        if (v != null && v.javaClass != value.javaClass) {
            throw ThrioException("Type of value is not ${v.javaClass}")
        }
        if (v != value) {
            params[key] = value
            v = ModuleJsonSerializers.serializeParams(value)
            if (v != null && v.canTransToFlutter()) {
                FlutterEngineFactory.setModuleContextValue(v, key)
            }
        }
    }

    fun remove(key: String): Any? {
        val v = params.remove(key)
        if (v != null) {
            FlutterEngineFactory.setModuleContextValue(null, key)
        }
        return v
    }

}
