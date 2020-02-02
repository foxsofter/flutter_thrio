// Copyright (c) 2019/12/20, 10:54:31 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'dart:async';

mixin ThrioModule {
  static final _modules = <Type, ThrioModule>{};

  ThrioModule operator [](Type t) => _modules[t];

  /// A function for module initialization that will call
  /// the `onPageRegister`, `onSyncInit` and `onAsyncInit`
  /// methods of all modules.
  ///
  static void init() {
    final values = _modules.values;
    for (final module in values) {
      module.onPageRegister();
    }
    for (final module in values) {
      module.onSyncInit();
    }
    Future.microtask(() {
      for (final module in values) {
        module.onAsyncInit();
      }
    });
  }

  /// A function for registering a module, which will call
  /// the `onModuleRegister` function of the `module`.
  ///
  static void register(ThrioModule module) {
    if (!_modules.containsKey(module.runtimeType)) {
      _modules[module.runtimeType] = module;
      module.onModuleRegister();
    }
  }

  /// A function for registering submodules.
  ///
  void onModuleRegister() {}

  /// A function for registering a page builder.
  ///
  void onPageRegister() {}

  /// A function for module initialization.
  ///
  void onSyncInit() {}

  /// A function for module asynchronous initialization.
  ///
  void onAsyncInit() {}
}
