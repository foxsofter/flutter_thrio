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

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../navigator/navigator_types.dart';
import '../navigator/thrio_navigator.dart';

mixin ThrioModule {
  static final _modules = <Type, ThrioModule>{};

  ThrioModule operator [](Type t) => _modules[t];

  /// A function for registering a module, which will call
  /// the `onModuleRegister` function of the `module`.
  ///
  void registerModule(ThrioModule module) {
    if (!_modules.containsKey(module.runtimeType)) {
      _modules[module.runtimeType] = module;
      module.onModuleRegister();
    }
  }

  /// A function for module initialization that will call
  /// the `onPageRegister`, `onModuleInit` and `onModuleAsyncInit`
  /// methods of all modules.
  ///
  void initModule() {
    final values = _modules.values;
    for (final module in values) {
      module.onPageRegister();
    }
    for (final module in values) {
      module.onModuleInit();
    }
    Future.microtask(() {
      for (final module in values) {
        module.onModuleAsyncInit();
      }
    });
  }

  /// A function for registering submodules.
  ///
  void onModuleRegister() {}

  /// A function for registering a page builder.
  ///
  void onPageRegister() {}

  /// A function for module initialization.
  ///
  void onModuleInit() {}

  /// A function for module asynchronous initialization.
  ///
  void onModuleAsyncInit() {}

  /// Sets up a broadcast stream for receiving page notify events.
  ///
  /// return value is `params`.
  ///
  Stream<Map<String, dynamic>> onPageNotify({
    @required String name,
    @required String url,
    @required int index,
  }) =>
      ThrioNavigator.onPageNotify(
        url: url,
        index: index,
        name: name,
      );

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registerDefaultPageBuilder(
    NavigatorPageBuilder builder,
  ) =>
      ThrioNavigator.registerDefaultPageBuilder(builder);

  /// Register an page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registerPageBuilder(
    String url,
    NavigatorPageBuilder builder,
  ) =>
      ThrioNavigator.registerPageBuilder(url, builder);

  /// Register page builders for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registerPageBuilders(
    Map<String, NavigatorPageBuilder> builders,
  ) =>
      ThrioNavigator.registerPageBuilders(builders);
}
