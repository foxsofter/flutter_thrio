/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2022 foxsofter
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

package io.flutter.embedding.android

import android.content.Context
import com.foxsofter.flutter_thrio.BooleanCallback
import com.foxsofter.flutter_thrio.IntCallback
import io.flutter.embedding.engine.FlutterEngine

interface ThrioFlutterActivityBase {
    val engine: com.foxsofter.flutter_thrio.navigator.FlutterEngine?

    fun provideFlutterEngine(context: Context): FlutterEngine?

    fun cleanUpFlutterEngine(flutterEngine: FlutterEngine)

    fun onBackPressed()

    fun shouldMoveToBack(): Boolean = true

    fun shouldDestroyEngineWithHost(): Boolean

    fun onPush(arguments: Map<String, Any?>?, result: BooleanCallback)

    fun onNotify(arguments: Map<String, Any?>?, result: BooleanCallback)

    fun onMaybePop(arguments: Map<String, Any?>?, result: IntCallback)

    fun onPop(arguments: Map<String, Any?>?, result: BooleanCallback)

    fun onPopTo(arguments: Map<String, Any?>?, result: BooleanCallback)

    fun onRemove(arguments: Map<String, Any?>?, result: BooleanCallback)

    fun onReplace(arguments: Map<String, Any?>?, result: BooleanCallback)

    fun onCanPop(arguments: Map<String, Any?>?, result: BooleanCallback)
}