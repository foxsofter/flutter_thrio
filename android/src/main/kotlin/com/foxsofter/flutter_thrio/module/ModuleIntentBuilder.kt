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

package com.foxsofter.flutter_thrio.module

import com.foxsofter.flutter_thrio.VoidCallback
import com.foxsofter.flutter_thrio.navigator.FlutterIntentBuilder
import com.foxsofter.flutter_thrio.navigator.IntentBuilder

interface ModuleIntentBuilder {

    fun onIntentBuilderRegister(moduleContext: ModuleContext) {

    }

    fun registerIntentBuilder(url: String, builder: IntentBuilder): VoidCallback {
        return ModuleIntentBuilders.intentBuilders.registry(url, builder)
    }

    fun registerIntentBuilders(builders: Map<String, IntentBuilder>): VoidCallback {
        return ModuleIntentBuilders.intentBuilders.registryAll(builders)
    }

    fun setFlutterIntentBuilder(builder: FlutterIntentBuilder) {
        ModuleIntentBuilders.flutterIntentBuilder = builder
    }
}