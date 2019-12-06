// Copyright (c) 2019/11/27, 19:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'registry/registry_set_map.dart';

typedef MethodHandler = Future<dynamic> Function(Map arguments);

class RouterChannel {
  factory RouterChannel({String channel}) {
    if (channel?.isEmpty ?? true) {
      return _defaultInstance;
    }
    _instanceCaches[channel] ??= RouterChannel._(channel: channel);
    return _instanceCaches[channel];
  }

  RouterChannel._({String channel = '__thrio_router__'})
      : _channel = MethodChannel(channel) {
    _channel.setMethodCallHandler((call) {
      final handlers = _methodHandlers[call.method];
      final arguments = call.arguments;
      if (arguments is Map && (handlers?.isNotEmpty ?? false)) {
        for (final it in handlers) {
          it(arguments);
        }
      }
      return;
    });
  }

  Future<T> invokeMethod<T>(String method, [Map arguments]) =>
      _channel.invokeMethod(method, arguments);

  Future<List<T>> invokeListMethod<T>(String method, [Map arguments]) =>
      _channel.invokeListMethod(method, arguments);

  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [Map arguments]) =>
      _channel.invokeMapMethod(method, arguments);

  VoidCallback registryMethodHandler(String method, MethodHandler handler) =>
      _methodHandlers.registry(method, handler);

  final _methodHandlers = RegistrySetMap<String, MethodHandler>();

  final MethodChannel _channel;

  static final _defaultInstance = RouterChannel._();

  static final _instanceCaches = <String, RouterChannel>{};
}
