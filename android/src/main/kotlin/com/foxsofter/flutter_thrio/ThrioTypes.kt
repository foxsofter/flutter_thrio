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

package com.foxsofter.flutter_thrio

/**
 * Signature of callbacks that have no arguments.
 */
typealias VoidCallback = () -> Unit

/**
 * Signature of callbacks with boolean parameters.
 */
typealias BooleanCallback = (Boolean) -> Unit

/**
 * Signature of callbacks with nullable boolean parameters.
 */
typealias NullableBooleanCallback = (Boolean?) -> Unit

/**
 * Signature of callbacks with Int? parameters.
 */
typealias NullableIntCallback = (Int?) -> Unit

/**
 * Signature of callbacks with any parameters.
 */
typealias NullableAnyCallback = (Any?) -> Unit

/**
 * Signature for a block that serializer json object to map.
 */
typealias JsonSerializer<T> = (T) -> Map<String, Any?>?

/**
 * Signature for a block that deserialize json map to object.
 */
typealias JsonDeserializer<T> = (Map<String, Any?>) -> T?

/**
 * Signature for a callbacks that handlers channel method invocation.
 */
typealias MethodHandler = (Map<String, Any?>?, NullableAnyCallback) -> Unit

/**
 * Signature for a callbacks that handlers channel event handling.
 */
typealias EventHandler = (Map<String, Any?>?, NullableAnyCallback) -> Unit