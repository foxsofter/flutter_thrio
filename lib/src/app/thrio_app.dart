// Copyright (c) 2019/1/6, 21:48:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../extension/stateful_widget.dart';
import '../registry/registry_map.dart';
import '../router/thrio_navigator.dart';
import '../router/thrio_page.dart';
import '../router/thrio_page_observer.dart';
import '../router/thrio_router.dart';
import '../thrio_types.dart';

class ThrioApp implements ThrioRouter {
  factory ThrioApp() => _default;

  ThrioApp._()
      : _pageBuilders = RegistryMap<String, PageBuilder>(),
        _channel = ThrioChannel(channel: '__thrio_app__') {
    _pageObserver = ThrioPageObserver(_channel);
  }

  static final _default = ThrioApp._();

  final defaultUrl = '/';

  final ThrioChannel _channel;

  final RegistryMap<String, PageBuilder> _pageBuilders;

  ThrioPageObserver _pageObserver;

  ThrioNavigator _navigator;

  /// Assigned when the `builder` method is called.
  ///
  ThrioNavigatorState get navigatorState =>
      _navigator.tryStateOf<ThrioNavigatorState>();

  /// Get current container.
  ///
  ThrioPage get current =>
      _navigator.tryStateOf<ThrioNavigatorState>()?.current;

  TransitionBuilder builder({
    TransitionBuilder builder,
    ThrioRouteFactory willPush,
    ThrioRouteFactory didPush,
  }) =>
      (context, child) {
        assert(child is Navigator, 'child must be a Navigator.');

        _navigator = ThrioNavigator(
            key: GlobalKey<ThrioNavigatorState>(),
            navigator: child is Navigator ? child : null,
            onWillPushRoute: willPush,
            onDidPushRoute: didPush);

        if (builder != null) {
          return builder(context, _navigator);
        } else {
          return _navigator;
        }
      };

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registryDefaultPageBuilder(PageBuilder builder) =>
      _pageBuilders.registry(defaultUrl, builder);

  /// Register an page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registryPageBuilder(String url, PageBuilder builder) =>
      _pageBuilders.registry(url, builder);

  /// Register page builders for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registryPageBuilders(Map<String, PageBuilder> builders) =>
      _pageBuilders.registryAll(builders);

  // Get page builder for url.
  //
  PageBuilder pageBuilder(String url) => _pageBuilders[url];

  /// Sets up a broadcast stream for receiving page lifecycle events.
  ///
  /// return value is `index`.
  ///
  Stream<int> onPageLifecycleStream(
    PageLifecycle lifecycle,
    String url, {
    int index,
  }) =>
      _pageObserver.onPageLifecycleStream(
        lifecycle,
        url,
        index: index,
      );

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

  @override
  Future<bool> push(
    String url, {
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

  @override
  Future<bool> notify(
    String name,
    String url, {
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

  @override
  Future<bool> pop({
    String url = '',
    int index = 0,
    bool animated = true,
  }) {
    final arguments = <String, dynamic>{
      'url': url,
      'index': index,
      'animated': animated,
    };
    return _channel.invokeMethod<bool>('pop', arguments);
  }

  @override
  Future<bool> popTo(
    String url, {
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
}
