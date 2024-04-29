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

import 'package:flutter/material.dart';

import '../channel/thrio_channel.dart';
import '../extension/thrio_object.dart';
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorRouteSendChannel {
  NavigatorRouteSendChannel(ThrioChannel channel) : _channel = channel;

  final ThrioChannel _channel;

  Future<int> push<TParams>({
    required String url,
    TParams? params,
    bool animated = true,
    String? fromURL,
    String? innerURL,
  }) async {
    final arguments = <String, dynamic>{
      'url': url,
      'animated': animated,
      'params': _serializeParams<TParams>(url: url, params: params),
    };
    if (fromURL?.isNotEmpty == true) {
      arguments['fromURL'] = fromURL;
    }
    if (innerURL?.isNotEmpty == true) {
      arguments['innerURL'] = innerURL;
    }
    return _channel
        .invokeMethod<int>('push', arguments)
        .then((value) => value ?? 0);
  }

  Future<bool> notify<TParams>({
    String? url,
    int index = 0,
    required String name,
    TParams? params,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'name': name,
      'params': _serializeParams<TParams>(url: url, params: params),
    };
    return _channel
        .invokeMethod<bool>('notify', arguments)
        .then((it) => it ?? false);
  }

  Future<bool> canPop<TParams>() =>
      _channel.invokeMethod<bool>('canPop').then((it) => it ?? false);

  Future<bool> pop<TParams>({
    TParams? params,
    bool animated = true,
  }) async {
    final settings = await lastRoute();
    final url = settings?.url;
    final arguments = <String, dynamic>{
      'params': _serializeParams<TParams>(url: url, params: params),
      'animated': animated,
    };
    return _channel
        .invokeMethod<bool>('pop', arguments)
        .then((it) => it ?? false);
  }

  Future<bool> popFlutter<TParams>({
    TParams? params,
    bool animated = true,
  }) {
    final settings =
        ThrioNavigatorImplement.shared().lastFlutterRoute()?.settings;
    final url = settings?.url;
    final arguments = <String, dynamic>{
      'params': _serializeParams<TParams>(url: url, params: params),
      'animated': animated,
    };
    return _channel
        .invokeMethod<bool>('popFlutter', arguments)
        .then((it) => it ?? false);
  }

  Future<bool> maybePop<TParams>({
    TParams? params,
    bool animated = true,
  }) async {
    final settings = await lastRoute();
    final url = settings?.url;
    final arguments = <String, dynamic>{
      'params': _serializeParams<TParams>(url: url, params: params),
      'animated': animated,
    };
    return _channel
        .invokeMethod<bool>('maybePop', arguments)
        .then((it) => it ?? false);
  }

  Future<bool> isInitialRoute({
    required String url,
    int index = 0,
  }) {
    final arguments = <String, dynamic>{'url': url, 'index': index};
    return _channel
        .invokeMethod<bool>('isInitialRoute', arguments)
        .then((it) => it ?? false);
  }

  Future<bool> popTo({
    required String url,
    int index = 0,
    bool animated = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'animated': animated
    };
    return _channel
        .invokeMethod<bool>('popTo', arguments)
        .then((it) => it ?? false);
  }

  Future<bool> remove({
    required String url,
    int index = 0,
    bool animated = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'animated': animated,
    };
    return _channel
        .invokeMethod<bool>('remove', arguments)
        .then((it) => it ?? false);
  }

  Future<int> replace({
    required String url,
    int index = 0,
    required String newUrl,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'newUrl': newUrl,
    };
    return _channel
        .invokeMethod<int>('replace', arguments)
        .then((it) => it ?? 0);
  }

  Future<RouteSettings?> lastRoute({String? url}) {
    final arguments = (url == null || url.isEmpty)
        ? <String, dynamic>{}
        : <String, dynamic>{'url': url};
    return _channel
        .invokeMethod<String>('lastRoute', arguments)
        .then<RouteSettings?>(
            (value) => value == null ? null : RouteSettings(name: value));
  }

  Future<List<RouteSettings>> allRoutes({String? url}) {
    final arguments = (url == null || url.isEmpty)
        ? <String, dynamic>{}
        : <String, dynamic>{'url': url};
    return _channel
        .invokeListMethod<String>('allRoutes', arguments)
        .then<List<RouteSettings>>((values) => values == null
            ? <RouteSettings>[]
            : values
                .map<RouteSettings>((value) => RouteSettings(name: value))
                .toList());
  }

  Future<bool> setPopDisabled({
    required String url,
    required int index,
    bool disabled = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'disabled': disabled
    };
    return _channel
        .invokeMethod<bool>('setPopDisabled', arguments)
        .then((it) => it ?? false);
  }

  dynamic _serializeParams<TParams>({
    String? url,
    TParams? params,
  }) {
    if (params == null) {
      return null;
    }
    final type = params.runtimeType;
    if (type != dynamic && type != Object && !params.isSimpleType) {
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
