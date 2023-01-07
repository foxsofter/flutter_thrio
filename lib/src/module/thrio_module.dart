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

// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../exception/thrio_exception.dart';
import '../navigator/navigator_logger.dart';
import '../navigator/navigator_types.dart';
import 'module_anchor.dart';
import 'module_expando.dart';
import 'module_json_deserializer.dart';
import 'module_json_serializer.dart';
import 'module_page_builder.dart';
import 'module_page_observer.dart';
import 'module_param_scheme.dart';
import 'module_route_action.dart';
import 'module_route_builder.dart';
import 'module_route_custom_handler.dart';
import 'module_route_observer.dart';
import 'module_route_transitions_builder.dart';

part 'module_context.dart';

mixin ThrioModule {
  /// Modular initialization function, needs to be called once during App initialization.
  ///
  static Future<void> init(
    final ThrioModule rootModule, {
    final String? entrypoint,
  }) async {
    if (anchor.modules.length == 1) {
      throw ThrioException('init method can only be called once.');
    } else {
      final moduleContext = entrypoint == null
          ? ModuleContext()
          : ModuleContext(entrypoint: entrypoint);
      moduleOf[moduleContext] = anchor;
      anchor
        .._moduleContext = moduleContext
        ..registerModule(rootModule, moduleContext);
      await anchor.onModuleInit(moduleContext);
      await anchor.initModule();
    }
  }

  /// Get instance by `T`, `url` and `key`.
  ///
  /// `T` can be `ThrioModule`, `NavigatorPageBuilder`, `JsonSerializer`,
  /// `JsonDeserializer`, `ProtobufSerializer`, `ProtobufDeserializer`,
  /// `RouteTransitionsBuilder`, default is `ThrioModule`.
  ///
  /// If `T` is `ThrioModule`, returns the last module matched by the `url`.
  ///
  /// If `T` is `ThrioModule`, `RouteTransitionsBuilder` or
  /// `NavigatorPageBuilder`, then `url` must not be null or empty.
  ///
  /// If `T` is not `ThrioModule`, `RouteTransitionsBuilder` or
  /// `NavigatorPageBuilder`, and `url` is null or empty, find instance of `T`
  /// in all modules.
  ///
  static T? get<T>({final String? url, final String? key}) =>
      anchor.get<T>(url: url, key: key);

  /// Returns true if the `url` has been registered.
  ///
  static bool contains(final String url) =>
      anchor.get<NavigatorPageBuilder>(url: url) != null;

  /// Get instances by `T` and `url`.
  ///
  /// `T` can not be optional. Can be `NavigatorPageObserver`,
  /// `NavigatorRouteObserver`.
  ///
  /// If `T` is `NavigatorPageObserver`, returns all page observers
  /// matched by `url`.
  ///
  /// If `T` is `NavigatorRouteObserver`, returns all route observers
  /// matched by `url`.
  ///
  static Iterable<T> gets<T>({required final String url}) =>
      anchor.gets<T>(url);

  @protected
  final modules = <String, ThrioModule>{};

  /// A [Key] is an identifier for a module.
  ///
  @protected
  String get key => '';

  /// Get parent module.
  ///
  @protected
  ThrioModule? get parent => parentOf[this];

  /// `ModuleContext` of current module.
  ///
  @protected
  ModuleContext get moduleContext => _moduleContext;
  late ModuleContext _moduleContext;

  /// A function for registering a module, which will call
  /// the `onModuleRegister` function of the `module`.
  ///
  @protected
  void registerModule(
    final ThrioModule module,
    final ModuleContext moduleContext,
  ) {
    if (modules.containsKey(module.key)) {
      throw ThrioException(
          'A module with the same key ${module.key} already exists');
    } else {
      final submoduleContext =
          ModuleContext(entrypoint: moduleContext.entrypoint);
      moduleOf[submoduleContext] = module;
      modules[module.key] = module;
      parentOf[module] = this;
      module
        .._moduleContext = submoduleContext
        ..onModuleRegister(submoduleContext);
    }
  }

  /// A function for module initialization that will call the
  /// `onModuleInit`, `onPageBuilderRegister`,
  /// `onRouteTransitionsBuilderRegister`, `onPageObserverRegister`
  /// `onRouteObserverRegister`, `onJsonSerializerRegister`,
  /// `onJsonDeserializerRegister`, `onProtobufSerializerRegister`,
  /// `onProtobufDeserializerRegister` and `onModuleAsyncInit`
  /// methods of all modules.
  ///
  @protected
  Future<void> initModule() async {
    final values = modules.values;
    for (final module in values) {
      if (module is ModuleParamScheme) {
        module.onParamSchemeRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModuleRouteAction) {
        module.onRouteActionRegister(module._moduleContext);
      }
      if (module is ModuleRouteCustomHandler) {
        module.onRouteCustomHandlerRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModulePageBuilder) {
        module.onPageBuilderSetting(module._moduleContext);
      }
      if (module is ModuleRouteBuilder) {
        module.onRouteBuilderSetting(module._moduleContext);
      }
      if (module is ModuleRouteTransitionsBuilder) {
        module.onRouteTransitionsBuilderSetting(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModulePageObserver) {
        module.onPageObserverRegister(module._moduleContext);
      }
      if (module is ModuleRouteObserver) {
        module.onRouteObserverRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (module is ModuleJsonSerializer) {
        module.onJsonSerializerRegister(module._moduleContext);
      }
      if (module is ModuleJsonDeserializer) {
        module.onJsonDeserializerRegister(module._moduleContext);
      }
    }
    for (final module in values) {
      if (kDebugMode) {
        final sw = Stopwatch()..start();
        await module.onModuleInit(module._moduleContext);
        verbose('init: ${module.key} = ${sw.elapsedMicroseconds} µs');
        sw.stop();
      } else {
        await module.onModuleInit(module._moduleContext);
      }
      await module.initModule();
    }
    for (final module in values) {
      unawaited(module.onModuleAsyncInit(module._moduleContext));
    }
  }

  /// A function for registering submodules.
  ///
  @protected
  void onModuleRegister(final ModuleContext moduleContext) {}

  /// A function for module initialization.
  ///
  @protected
  Future<void> onModuleInit(final ModuleContext moduleContext) async {}

  /// Returns whether the module is loaded.
  ///
  @protected
  bool isLoaded = false;

  /// Called when the first page in the module is about to be pushed.
  ///
  @protected
  Future<void> onModuleLoading(final ModuleContext moduleContext) async =>
      verbose('onModuleLoading: $key');

  /// Called when the last page in the module is closed.
  ///
  @protected
  Future<void> onModuleUnloading(final ModuleContext moduleContext) async =>
      verbose('onModuleUnloading: $key');

  /// A function for module asynchronous initialization.
  ///
  @protected
  Future<void> onModuleAsyncInit(final ModuleContext moduleContext) async {}

  @protected
  bool get navigatorLogEnabled => navigatorLogging;

  @protected
  set navigatorLogEnabled(final bool enabled) => navigatorLogging = enabled;

  @override
  String toString() => '$key: ${modules.keys.toString()}';
}
