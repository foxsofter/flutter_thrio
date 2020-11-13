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
import 'package:flutter/widgets.dart';

import '../navigator/navigator_logger.dart';
import '../navigator/thrio_navigator_implement.dart';
import 'module_context.dart';
import 'module_page_builder.dart';
import 'module_page_observer.dart';
import 'module_route_observer.dart';
import 'module_route_transitions_builder.dart';

mixin ThrioModule {
  static final _modules = <Type, ThrioModule>{};

  ThrioModule operator [](Type t) => _modules[t];

  /// A function for registering a module, which will call
  /// the `onModuleRegister` function of the `module`.
  ///
  void registerModule(ModuleContext moduleContext, ThrioModule module) {
    if (!_modules.containsKey(module.runtimeType)) {
      _modules[module.runtimeType] = module;
      module.onModuleRegister(moduleContext);
    }
  }

  /// A function for module initialization that will call
  /// the `onPageRegister`, `onModuleInit` and `onModuleAsyncInit`
  /// methods of all modules.
  ///
  void initModule(ModuleContext moduleContext) {
    ThrioNavigatorImplement.shared().init(moduleContext);

    final values = _modules.values;
    for (final module in values) {
      module.onModuleInit(moduleContext);
    }
    for (final module in values) {
      if (module is ModulePageBuilder) {
        module.onPageBuilderRegister(moduleContext);
      }
      if (module is ModulePageObserver) {
        module.onPageObserverRegister(moduleContext);
      }
      if (module is ModuleRouteObserver) {
        module.onRouteObserverRegister(moduleContext);
      }
      if (module is ModuleRouteTransitionsBuilder) {
        module.onRouteTransitionsBuilderRegister(moduleContext);
      }
    }
    Future.microtask(() {
      for (final module in values) {
        module.onModuleAsyncInit(moduleContext);
      }
    });
  }

  /// A function for registering submodules.
  ///
  void onModuleRegister(ModuleContext moduleContext) {}

  /// A function for module initialization.
  ///
  void onModuleInit(ModuleContext moduleContext) {}

  /// A function for module asynchronous initialization.
  ///
  void onModuleAsyncInit(ModuleContext moduleContext) {}

  /// Sets up a broadcast stream for receiving page notify events.
  ///
  /// return value is `params`.
  ///
  Stream onPageNotify({
    @required String name,
    @required String url,
    @required int index,
  }) =>
      ThrioNavigatorImplement.shared().onPageNotify(
        url: url,
        index: index,
        name: name,
      );

  bool get navigatorLogEnabled => navigatorLogging;
  set navigatorLogEnabled(bool enabled) => navigatorLogging = enabled;
}
