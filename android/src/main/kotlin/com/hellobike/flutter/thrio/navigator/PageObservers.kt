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

package com.hellobike.flutter.thrio.navigator

import com.hellobike.flutter.thrio.registry.RegistrySet

internal object PageObservers : PageObserver {
    private const val TAG = "PageObservers"

    val observers by lazy { RegistrySet<PageObserver>() }

    init {
        observers.registry(FlutterEngineFactory)
    }

    override fun willAppear(routeSettings: RouteSettings) {
        observers.forEach {
            it.willAppear(routeSettings)
        }
        Log.v(TAG, "willAppear: url->${routeSettings.url} " +
                "index->${routeSettings.index} " +
                "params->${routeSettings.params?.toString()}")
    }

    override fun didAppear(routeSettings: RouteSettings) {
        observers.forEach {
            it.didAppear(routeSettings)
        }
        Log.v(TAG, "didAppear: url->${routeSettings.url} " +
                "index->${routeSettings.index} " +
                "params->${routeSettings.params?.toString()}")
        PageRoutes.lastRouteHolder(routeSettings.url, routeSettings.index)?.activity?.get()?.apply {
            NavigationController.Notify.doNotify(this)
        }
    }

    override fun willDisappear(routeSettings: RouteSettings) {
        observers.forEach {
            it.willDisappear(routeSettings)
        }
        Log.v(TAG, "willDisappear: url->${routeSettings.url} " +
                "index->${routeSettings.index} " +
                "params->${routeSettings.params?.toString()}")
    }

    override fun didDisappear(routeSettings: RouteSettings) {
        observers.forEach {
            it.didDisappear(routeSettings)
        }
        Log.v(TAG, "didDisappear: url->${routeSettings.url} " +
                "index->${routeSettings.index} " +
                "params->${routeSettings.params?.toString()}")
    }
}