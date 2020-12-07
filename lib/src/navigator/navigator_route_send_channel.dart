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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../channel/thrio_channel.dart';
import '../extension/thrio_object.dart';
import 'thrio_navigator_implement.dart';

class NavigatorRouteSendChannel {
  const NavigatorRouteSendChannel(ThrioChannel channel) : _channel = channel;

  final ThrioChannel _channel;

  Future<int> push<TParams>({
    @required String url,
    TParams params,
    bool animated = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'animated': animated,
      'params': _serializeParams<TParams>(params),
    };
    return _channel.invokeMethod<int>('push', arguments);
  }

  Future<bool> notify<TParams>({
    String url,
    int index,
    @required String name,
    TParams params,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'name': name,
      'params': _serializeParams<TParams>(params),
    };
    return _channel.invokeMethod<bool>('notify', arguments);
  }

  Future<bool> pop<TParams>({
    TParams params,
    bool animated = true,
  }) {
    final arguments = <String, dynamic>{
      'params': _serializeParams<TParams>(params),
      'animated': animated,
    };
    return _channel.invokeMethod<bool>('pop', arguments);
  }

  Future<bool> popTo({
    @required String url,
    int index,
    bool animated = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'animated': animated,
    };
    return _channel.invokeMethod<bool>('popTo', arguments);
  }

  Future<bool> remove({
    @required String url,
    int index,
    bool animated = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'animated': animated,
    };
    return _channel.invokeMethod<bool>('remove', arguments);
  }

  Future<int> lastIndex({String url}) {
    final arguments = (url?.isEmpty ?? true)
        ? <String, dynamic>{}
        : <String, dynamic>{'url': url};
    return _channel.invokeMethod<int>('lastIndex', arguments);
  }

  Future<List<int>> allIndexes({@required String url}) =>
      _channel.invokeListMethod<int>('allIndexes', {'url': url});

  Future<RouteSettings> lastRoute({String url}) {
    final arguments = (url?.isEmpty ?? true)
        ? <String, dynamic>{}
        : <String, dynamic>{'url': url};
    return _channel
        .invokeMethod<String>('lastRoute', arguments)
        .then<RouteSettings>((value) => RouteSettings(name: value));
  }

  Future<List<RouteSettings>> allRoutes({String url}) {
    final arguments = (url?.isEmpty ?? true)
        ? <String, dynamic>{}
        : <String, dynamic>{'url': url};
    return _channel
        .invokeListMethod<String>('allRoutes', arguments)
        .then<List<RouteSettings>>((values) => values
            .map<RouteSettings>((value) => RouteSettings(name: value))
            .toList());
  }

  Future<bool> setPopDisabled({
    @required String url,
    @required int index,
    bool disabled = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'disabled': disabled,
    };
    return _channel.invokeMethod<bool>('setPopDisabled', arguments);
  }

  Future registerUrls(List<String> urls) =>
      _channel.invokeMethod('registerUrls', {'urls': urls});

  Future unregisterUrls(List<String> urls) =>
      _channel.invokeMethod('unregisterUrls', {'urls': urls});

  dynamic _serializeParams<TParams>(TParams params) {
    if (params == null) {
      return null;
    }
    final type = params.runtimeType;
    if (type != dynamic && params.isComplexType) {
      final serializeParams = ThrioNavigatorImplement.shared()
          .jsonSerializers[type]
          ?.call(<type>() => params as type); // ignore: avoid_as
      if (serializeParams != null) {
        serializeParams['__thrio_TParams__'] = type.toString();
        return serializeParams;
      }
    }
    return params;
  }
}
