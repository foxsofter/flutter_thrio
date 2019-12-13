// Copyright (c) 2019/11/27, 19:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'registry/registry_map.dart';

typedef MethodHandler = Future<dynamic> Function([
  Map<String, dynamic> arguments,
]);

const String _kEventNameKey = '__event_name__';

class RouterChannel {
  factory RouterChannel({String channel = '__thrio_router__'}) =>
      _instanceCaches[channel] ??= RouterChannel._(channel: channel);

  RouterChannel._({String channel})
      : _methodChannel = MethodChannel('_method_$channel'),
        _eventChannel = EventChannel('_event_$channel') {
    _methodChannel.setMethodCallHandler((call) {
      final handler = _methodHandlers[call.method];
      final args = call.arguments;
      if (handler != null && args is Map) {
        final arguments = args.cast<String, dynamic>();
        return handler(arguments);
      }
      return Future.value();
    });
    _eventChannel
        .receiveBroadcastStream()
        .map<Map<String, dynamic>>(
            (data) => data is Map ? data.cast<String, dynamic>() : null)
        .where((data) => data.containsKey(_kEventNameKey))
        .listen((data) {
      final eventName = data.remove(_kEventNameKey);
      final controllers = _eventControllers[eventName];
      for (final controller in controllers) {
        controller.add(data);
      }
    });
  }

  static final _instanceCaches = <String, RouterChannel>{};

  final _methodHandlers = RegistryMap<String, MethodHandler>();

  final MethodChannel _methodChannel;

  final EventChannel _eventChannel;

  final _eventControllers = <String, Set<StreamController>>{};

  Future<List<T>> invokeListMethod<T>(String method, [Map arguments]) =>
      _methodChannel.invokeListMethod(method, arguments);

  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [Map arguments]) =>
      _methodChannel.invokeMapMethod(method, arguments);

  Future<T> invokeMethod<T>(String method, [Map arguments]) =>
      _methodChannel.invokeMethod(method, arguments);

  VoidCallback onMethodCall(String method, MethodHandler handler) =>
      _methodHandlers.registry(method, handler);

  Stream onEventHanddling(String event) {
    final controller = StreamController();
    controller
      ..onListen = () {
        _eventControllers[event] ??= <StreamController>{};
        _eventControllers[event].add(controller);
      }
      ..onCancel = () {
        _eventControllers[event].remove(controller);
      };
    return controller.stream;
  }
}
