// Copyright (c) 2019/2/21, 17:27:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';

import '../channel/thrio_channel.dart';

class NavigatorSendChannel {
  NavigatorSendChannel(ThrioChannel channel) : _channel = channel;

  final ThrioChannel _channel;

  Future<bool> push({
    @required String url,
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'animated': animated,
      'params': params,
    };
    return _channel.invokeMethod<bool>('push', arguments);
  }

  Future<bool> notify({
    @required String name,
    @required String url,
    int index = 0,
    Map<String, dynamic> params = const {},
  }) {
    final arguments = <String, dynamic>{
      'name': name,
      'url': url,
      'index': index,
      'params': params,
    };
    return _channel.invokeMethod<bool>('notify', arguments);
  }

  Future<bool> pop({bool animated = true}) {
    final arguments = <String, dynamic>{
      'animated': animated,
    };
    return _channel.invokeMethod<bool>('pop', arguments);
  }

  Future<bool> popTo({
    @required String url,
    int index = 0,
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
    String url = '',
    int index = 0,
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

  Future<List<int>> allIndex(String url) =>
      _channel.invokeListMethod<int>('allIndex', {'url': url});

  Future<bool> setPopDisabled({
    @required String url,
    int index,
    bool disabled = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'disabled': disabled,
    };
    return _channel.invokeMethod<bool>('setPopDisabled', arguments);
  }
}