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

import 'package:flutter/material.dart';

import '../async/async_task_queue.dart';
import '../channel/thrio_channel.dart';
import '../extension/thrio_object.dart';
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
import 'navigator_route_settings.dart';

class NavigatorRouteSendChannel {
  NavigatorRouteSendChannel(final ThrioChannel channel) : _channel = channel;

  final _timeLimit = const Duration(milliseconds: 300);

  final ThrioChannel _channel;

  final _taskQueue = AsyncTaskQueue();

  Future<int> push<TParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
  }) {
    Future<int> pushFuture() {
      final arguments = <String, dynamic>{
        'url': url,
        'animated': animated,
        'params': _serializeParams<TParams>(url: url, params: params),
      };
      return _channel
          .invokeMethod<int>('push', arguments)
          .then((final value) => value ?? 0);
    }

    return _taskQueue
        .add(pushFuture, timeLimit: _timeLimit)
        .then((final value) => value ?? 0);
  }

  Future<bool> notify<TParams>({
    final String? url,
    final int index = 0,
    required final String name,
    final TParams? params,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'name': name,
      'params': _serializeParams<TParams>(url: url, params: params),
    };
    return _channel
        .invokeMethod<bool>('notify', arguments)
        .then((final it) => it ?? false);
  }

  Future<bool> canPop<TParams>() =>
      _channel.invokeMethod<bool>('canPop').then((final it) => it ?? false);

  Future<bool> pop<TParams>({
    final TParams? params,
    final bool animated = true,
  }) {
    Future<bool> popFuture() async {
      final settings = await lastRoute();
      final url = settings?.url;
      final arguments = <String, dynamic>{
        'params': _serializeParams<TParams>(url: url, params: params),
        'animated': animated,
      };
      return _channel
          .invokeMethod<bool>('pop', arguments)
          .then((final it) => it ?? false);
    }

    return _taskQueue
        .add(popFuture, timeLimit: _timeLimit)
        .then((final value) => value == true);
  }

  Future<bool> maybePop<TParams>({
    final TParams? params,
    final bool animated = true,
  }) async {
    final settings = await lastRoute();
    final url = settings?.url;
    final arguments = <String, dynamic>{
      'params': _serializeParams<TParams>(url: url, params: params),
      'animated': animated,
    };
    return _channel
        .invokeMethod<bool>('maybePop', arguments)
        .then((final it) => it ?? false);
  }

  Future<bool> isInitialRoute({
    required final String url,
    final int index = 0,
  }) {
    final arguments = <String, dynamic>{'url': url, 'index': index};
    return _channel
        .invokeMethod<bool>('isInitialRoute', arguments)
        .then((final it) => it ?? false);
  }

  Future<bool> popTo({
    required final String url,
    final int index = 0,
    final bool animated = true,
  }) {
    Future<bool> popToFuture() {
      final arguments = <String, dynamic>{
        'url': url,
        'index': index,
        'animated': animated
      };
      return _channel
          .invokeMethod<bool>('popTo', arguments)
          .then((final it) => it ?? false);
    }

    return _taskQueue
        .add(popToFuture, timeLimit: _timeLimit)
        .then((final value) => value == true);
  }

  Future<bool> remove({
    required final String url,
    final int index = 0,
    final bool animated = true,
  }) {
    Future<bool> removeFuture() {
      final arguments = <String, dynamic>{
        'url': url,
        'index': index,
        'animated': animated,
      };
      return _channel
          .invokeMethod<bool>('remove', arguments)
          .then((final it) => it ?? false);
    }

    return _taskQueue
        .add(removeFuture, timeLimit: _timeLimit)
        .then((final value) => value == true);
  }

  Future<int> replace({
    required final String url,
    final int index = 0,
    required final String newUrl,
  }) {
    Future<int> replaceFuture() {
      final arguments = <String, dynamic>{
        'url': url,
        'index': index,
        'newUrl': newUrl,
      };
      return _channel
          .invokeMethod<int>('replace', arguments)
          .then((final it) => it ?? 0);
    }

    return _taskQueue
        .add(replaceFuture, timeLimit: _timeLimit)
        .then((final value) => value ?? 0);
  }

  Future<RouteSettings?> lastRoute({final String? url}) {
    final arguments = (url == null || url.isEmpty)
        ? <String, dynamic>{}
        : <String, dynamic>{'url': url};
    return _channel
        .invokeMethod<String>('lastRoute', arguments)
        .then<RouteSettings?>(
            (final value) => value == null ? null : RouteSettings(name: value));
  }

  Future<List<RouteSettings>> allRoutes({final String? url}) {
    final arguments = (url == null || url.isEmpty)
        ? <String, dynamic>{}
        : <String, dynamic>{'url': url};
    return _channel
        .invokeListMethod<String>('allRoutes', arguments)
        .then<List<RouteSettings>>((final values) => values == null
            ? <RouteSettings>[]
            : values
                .map<RouteSettings>((final value) => RouteSettings(name: value))
                .toList());
  }

  Future<bool> setPopDisabled({
    required final String url,
    required final int index,
    final bool disabled = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'disabled': disabled
    };
    return _channel
        .invokeMethod<bool>('setPopDisabled', arguments)
        .then((final it) => it ?? false);
  }

  dynamic _serializeParams<TParams>({
    final String? url,
    final TParams? params,
  }) {
    if (params == null) {
      return null;
    }
    final type = params.runtimeType;
    if (type != dynamic && type != Object && !params.isTransferableType) {
      final serializeParams =
          ThrioModule.get<JsonSerializer>(key: type.toString())
              ?.call(<type>() => params as type); // ignore: avoid_as
      if (serializeParams != null) {
        serializeParams['__thrio_TParams__'] = type.toString();
        // 判断 url 是否是当前引擎下的，如果是则直接缓存参数并传递 hashCode
        if (url != null && ThrioModule.contains(url)) {
          final hashCode = params.hashCode;
          anchor.set(hashCode, params);
          serializeParams['__thrio_Params_HashCode__'] = hashCode;
        }
        return serializeParams;
      }
      // 判断 url 是否是当前引擎下的，如果是则直接缓存参数并传递 hashCode
      if (url != null && ThrioModule.contains(url)) {
        final hashCode = params.hashCode;
        anchor.set(hashCode, params);
        return {'__thrio_Params_HashCode__': hashCode};
      }
    }
    return params;
  }
}
