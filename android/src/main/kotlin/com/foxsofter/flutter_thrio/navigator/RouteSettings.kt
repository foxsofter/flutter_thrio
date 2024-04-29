/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2019 foxsofter
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

package com.foxsofter.flutter_thrio.navigator

import com.foxsofter.flutter_thrio.module.ModuleJsonDeserializers

data class RouteSettings(val url: String, val index: Int) {

    var params: Any? = null
    var fromURL: String? = null
    var prevURL: String? = null
    var innerURL: String? = null
    var animated: Boolean = true
    var isNested: Boolean = false

    val name get() = "$index $url"

    fun toArguments() = toArgumentsWithParams(params)

    fun toArgumentsWithoutParams() = toArgumentsWithParams(null)

    private fun toArgumentsWithParams(params: Any?): Map<String, Any?> {
        val args = mutableMapOf<String, Any?>(
            "url" to url,
            "index" to index,
            "animated" to animated,
            "isNested" to isNested,
        )
        if (params != null) args["params"] = params
        if (fromURL?.isNotEmpty() == true) args["fromURL"] = fromURL
        if (prevURL?.isNotEmpty() == true) args["prevURL"] = prevURL
        if (innerURL?.isNotEmpty() == true) args["innerURL"] = innerURL
        return args.toMap()
    }

    fun toArgumentsWith(newUrl: String, newIndex: Int): Map<String, Any?> {
        val args = mutableMapOf<String, Any?>(
            "url" to url,
            "index" to index,
            "isNested" to isNested,
            "newUrl" to newUrl,
            "newIndex" to newIndex,
        )
        if (fromURL?.isNotEmpty() == true) args["fromURL"] = fromURL
        if (prevURL?.isNotEmpty() == true) args["prevURL"] = prevURL
        if (innerURL?.isNotEmpty() == true) args["innerURL"] = innerURL
        return args.toMap()
    }

    override fun equals(other: Any?): Boolean {
        return other != null && other is RouteSettings && url == other.url && index == other.index
    }

    override fun hashCode(): Int {
        return url.hashCode() xor index.hashCode()
    }

    companion object {
        @JvmStatic
        fun fromArguments(arguments: Map<String, Any?>): RouteSettings? {
            if (!arguments.containsKey("url")) {
                return null
            }
            val url = arguments["url"] as String
            val index = if (arguments["index"] != null) arguments["index"] as Int else 0
            val params = ModuleJsonDeserializers.deserializeParams(arguments["params"])
            val animated =
                if (arguments["animated"] != null) arguments["animated"] as Boolean else false
            val fromURL = arguments["fromURL"] as String?
            val prevURL = arguments["prevURL"] as String?
            val innerURL = arguments["innerURL"] as String?
            return RouteSettings(url, index).also {
                it.params = params
                it.animated = animated
                if (fromURL != null) it.fromURL = fromURL
                if (prevURL != null) it.prevURL = prevURL
                if (innerURL != null) it.innerURL = innerURL
            }
        }
    }
}
