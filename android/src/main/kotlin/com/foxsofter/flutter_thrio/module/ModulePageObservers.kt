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

import com.foxsofter.flutter_thrio.navigator.*
import com.foxsofter.flutter_thrio.registry.RegistrySet

internal object ModulePageObservers : PageObserver {
    private const val TAG = "ModulePageObservers"

    val observers by lazy { RegistrySet<PageObserver>() }

    init {
        observers.registry(FlutterEngineFactory)
    }

    override fun willAppear(routeSettings: RouteSettings) {
        observers.forEach {
            it.willAppear(routeSettings)
        }
        Log.i(
            TAG, "willAppear: url->${routeSettings.url} " +
                    "index->${routeSettings.index} "
        )
    }

    override fun didAppear(routeSettings: RouteSettings) {
        observers.forEach {
            it.didAppear(routeSettings)
        }
        Log.i(
            TAG, "didAppear: url->${routeSettings.url} " +
                    "index->${routeSettings.index} "
        )
        PageRoutes.lastRouteHolder(routeSettings.url, routeSettings.index)?.activity?.get()?.apply {
            NavigationController.Notify.doNotify(this)
        }
    }

    override fun willDisappear(routeSettings: RouteSettings) {
        observers.forEach {
            it.willDisappear(routeSettings)
        }
        Log.i(
            TAG, "willDisappear: url->${routeSettings.url} " +
                    "index->${routeSettings.index} "
        )
    }

    override fun didDisappear(routeSettings: RouteSettings) {
        observers.forEach {
            it.didDisappear(routeSettings)
        }
        Log.i(
            TAG, "didDisappear: url->${routeSettings.url} " +
                    "index->${routeSettings.index} "
        )
    }
}