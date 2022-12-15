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

import 'package:flutter/services.dart';

import '../navigator/navigator_logger.dart';
import '../registry/registry_map.dart';

typedef MethodHandler = Future<dynamic> Function([
  Map<String, dynamic>? arguments,
]);

const String _kEventNameKey = '__event_name__';

class ThrioChannel {
  factory ThrioChannel({final String channel = '__thrio_channel__'}) =>
      ThrioChannel._(channel: channel);

  ThrioChannel._({required final String channel}) : _channel = channel;

  final String _channel;

  final _methodHandlers = RegistryMap<String, MethodHandler>();

  MethodChannel? _methodChannel;

  EventChannel? _eventChannel;

  final _eventControllers = <String, List<StreamController<dynamic>>>{};

  Future<List<T>?> invokeListMethod<T>(final String method,
      [final Map<String, dynamic>? arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel?.invokeListMethod<T>(method, arguments) ??
        Future.value();
  }

  Future<Map<K, V>?> invokeMapMethod<K, V>(final String method,
      [final Map<String, dynamic>? arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel?.invokeMapMethod<K, V>(method, arguments) ??
        Future.value();
  }

  Future<T?> invokeMethod<T>(final String method,
      [final Map<String, dynamic>? arguments]) {
    _setupMethodChannelIfNeeded();
    return _methodChannel?.invokeMethod<T>(method, arguments) ?? Future.value();
  }

  VoidCallback registryMethodCall(
      final String method, final MethodHandler handler) {
    _setupMethodChannelIfNeeded();
    return _methodHandlers.registry(method, handler);
  }

  void sendEvent(final String name, [final Map<String, dynamic>? arguments]) {
    _setupEventChannelIfNeeded();
    final controllers = _eventControllers[name];
    if (controllers != null && controllers.isNotEmpty) {
      for (final controller in controllers) {
        controller.add(<String, dynamic>{
          if (arguments != null) ...arguments,
          _kEventNameKey: name
        });
      }
    }
  }

  Stream<Map<String, dynamic>> onEventStream(final String name) {
    _setupEventChannelIfNeeded();
    final controller = StreamController<Map<String, dynamic>>();
    controller
      ..onListen = () {
        _eventControllers[name] ??= <StreamController<dynamic>>[];
        _eventControllers[name]?.add(controller);
      }
      ..onCancel = () {
        controller.close();
        _eventControllers[name]?.remove(controller);
      };
    return controller.stream;
  }

  void _setupMethodChannelIfNeeded() {
    if (_methodChannel != null) {
      return;
    }
    _methodChannel = MethodChannel('_method_$_channel')
      ..setMethodCallHandler((final call) {
        final handler = _methodHandlers[call.method];
        final args = call.arguments;
        if (handler != null) {
          if (args is Map) {
            final arguments = args.cast<String, dynamic>();
            return handler(arguments);
          } else {
            return handler(null);
          }
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
          .map<Map<String, dynamic>>((final data) =>
              data is Map ? data.cast<String, dynamic>() : <String, dynamic>{})
          .where((final data) => data.containsKey(_kEventNameKey))
          .listen((final data) {
        verbose('Notify on $_channel $data');
        final eventName = data.remove(_kEventNameKey);
        final controllers = _eventControllers[eventName];
        if (controllers != null && controllers.isNotEmpty) {
          for (final controller in controllers) {
            controller.add(data);
          }
        }
      });
  }
}
