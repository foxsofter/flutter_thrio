// Copyright (c) 2019/1/6, 21:48:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../extension/thrio_stateful_widget.dart';
import '../logger/thrio_logger.dart';
import '../navigator/thrio_navigator.dart';
import '../navigator/thrio_page_observer.dart';
import '../navigator/thrio_page_route.dart';

class ThrioApp {
  factory ThrioApp() => _default;

  ThrioApp._() : _channel = ThrioChannel(channel: '__thrio_app__') {
    _pageObserver = ThrioPageObserver(_channel);
    _navigatorObserver = ThrioNavigatorObserver(_channel);
  }

  static final _default = ThrioApp._();

  final ThrioChannel _channel;

  ThrioChannel get cc => _channel;

  ThrioPageObserver _pageObserver;

  ThrioNavigatorObserver _navigatorObserver;

  ThrioNavigator _navigator;

  /// Assigned when the `build` method is called.
  ///
  ThrioNavigatorState get navigatorState =>
      _navigator.tryStateOf<ThrioNavigatorState>();

  TransitionBuilder build() => (context, child) => _navigator = ThrioNavigator(
        key: GlobalKey<ThrioNavigatorState>(),
        observer: _navigatorObserver,
        child: child is Navigator ? child : null,
      );

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registerDefaultPageBuilder(
    ThrioPageBuilder builder,
  ) =>
      ThrioNavigator.registerDefaultPageBuilder(builder);

  /// Register an page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registerPageBuilder(
    String url,
    ThrioPageBuilder builder,
  ) =>
      ThrioNavigator.registerPageBuilder(url, builder);

  /// Register page builders for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registerPageBuilders(
    Map<String, ThrioPageBuilder> builders,
  ) =>
      ThrioNavigator.registerPageBuilders(builders);

  /// Sets up a broadcast stream for receiving page notify events.
  ///
  /// return value is `params`.
  ///
  Stream<Map<String, dynamic>> onPageNotifyStream(
    String name,
    String url, {
    int index,
  }) =>
      _pageObserver.onPageNotifyStream(
        name,
        url,
        index: index,
      );

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
