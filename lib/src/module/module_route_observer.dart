// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'package:flutter/foundation.dart';

import '../navigator/navigator_route_observer.dart';
import '../registry/registry_set.dart';
import 'thrio_module.dart';

mixin ModuleRouteObserver on ThrioModule {
  @protected
  final routeObservers = RegistrySet<NavigatorRouteObserver>();

  /// A function for register a route observer.
  ///
  @protected
  void onRouteObserverRegister(ModuleContext moduleContext) {}

  /// Register observers for routing actions. Only the pages under the current module and
  /// sub-module take effect.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  /// Do not override this method.
  ///
  @protected
  VoidCallback registerRouteObserver(NavigatorRouteObserver routeObserver) =>
      routeObservers.registry(routeObserver);
}
