// Copyright (c) 2019/12/20, 10:54:31 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../thrio.dart';
import '../navigator/navigator_page_route.dart';

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
  Stream<Map<String, dynamic>> onPageNotifyStream(
    String name,
    String url, {
    int index,
  }) =>
      ThrioNavigator.onPageNotifyStream(name, url, index: index);

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
