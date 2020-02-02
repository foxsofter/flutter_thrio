// Copyright (c) 2019/11/27, 19:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../registry/registry_map.dart';

typedef MethodHandler = Future<dynamic> Function([
  Map<String, dynamic> arguments,
]);

const String _kEventNameKey = '__event_name__';

class ThrioChannel {
  factory ThrioChannel({String channel = '__thrio_channel__'}) =>
      _instanceCaches[channel] ??= ThrioChannel._(channel: channel);

  ThrioChannel._({String channel}) : _channel = channel;

  static final _instanceCaches = <String, ThrioChannel>{};

  final String _channel;

  final _methodHandlers = RegistryMap<String, MethodHandler>();

  OptionalMethodChannel _methodChannel;

  EventChannel _eventChannel;

  final _eventControllers = <String, Set<StreamController>>{};

  Future<List<T>> invokeListMethod<T>(String method, [Map arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel.invokeListMethod(method, arguments);
  }

  Future<Map<K, V>> invokeMapMethod<K, V>(String method, [Map arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel.invokeMapMethod(method, arguments);
  }

  Future<T> invokeMethod<T>(String method, [Map arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel.invokeMethod(method, arguments);
  }

  VoidCallback registryMethodCall(String method, MethodHandler handler) {
    _setupMethodChannelIfNeeded();
    return _methodHandlers.registry(method, handler);
  }

  void sendEvent(String name, [Map arguments]) {
    _setupEventChannelIfNeeded();
    final controllers = _eventControllers[name];
    if (controllers?.isNotEmpty ?? false) {
      for (final controller in controllers) {
        controller.add({...arguments, _kEventNameKey: name});
      }
    }
  }

  Stream<Map<String, dynamic>> onEventStream(String name) {
    _setupEventChannelIfNeeded();
    final controller = StreamController<Map<String, dynamic>>();
    controller
      ..onListen = () {
        _eventControllers[name] ??= <StreamController>{};
        _eventControllers[name].add(controller);
      }
      ..onCancel = () {
        controller.close();
        _eventControllers[name].remove(controller);
      };
    return controller.stream;
  }

  void _setupMethodChannelIfNeeded() {
    if (_methodChannel != null) {
      return;
    }
    _methodChannel = OptionalMethodChannel('_method_$_channel')
      ..setMethodCallHandler((call) {
        final handler = _methodHandlers[call.method];
        final args = call.arguments;
        if (handler != null && args is Map) {
          final arguments = args.cast<String, dynamic>();
          return handler(arguments);
        }
        return Future.value();
      });
  }

  void _setupEventChannelIfNeeded() {
    if (_eventChannel != null) {
      return;
    }
    _eventChannel = EventChannel('_event_$_channel')
      ..receiveBroadcastStream()
          .map<Map<String, dynamic>>(
              (data) => data is Map ? data.cast<String, dynamic>() : null)
          .where((data) => data?.containsKey(_kEventNameKey) ?? false)
          .listen((data) {
        final eventName = data.remove(_kEventNameKey);
        final controllers = _eventControllers[eventName];
        if (controllers?.isNotEmpty ?? false) {
          for (final controller in controllers) {
            controller.add(data);
          }
        }
      });
  }
}
