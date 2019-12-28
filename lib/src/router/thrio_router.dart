// Copyright (c) 2019/11/25, 19:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../extension/stateful_widget.dart';
import '../registry/registry_map.dart';
import '../thrio_types.dart';
import 'thrio_navigator.dart';
import 'thrio_page.dart';
import 'thrio_page_observer.dart';
import 'thrio_route_settings.dart';

/// A class that provides push, pop, popTo and notify page functions.
///
class ThrioRouter {
  factory ThrioRouter() => _default;

  ThrioRouter._();

  static final _default = ThrioRouter._();

  ThrioNavigator _navigator;

  final _pageBuilders = RegistryMap<String, PageBuilder>();

  final _defaultUrl = '/';

  final _channel = ThrioChannel();

  final _pageObserver = ThrioPageObserver();

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
  }) {
    if (Platform.isAndroid) {
      _channel.invokeMapMethod<String, dynamic>('pageOnStart').then((result) {
        final routeSettings = argumentsToRouteSettings(result);
        routeSettings ??
            _navigator
                .tryStateOf<ThrioNavigatorState>()
                ?.activate(routeSettings);
      });
    }
    return (context, child) {
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
  }

  /// Notify a page with `url` and `index`.
  ///
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

  /// Pop a page with `url` and `index` from native navigator.
  ///
  Future<bool> pop(
    String url, {
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

  /// Pop to a page with `url` and `index`.
  ///
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

  /// Push a page with `url` onto native navigator.
  ///
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

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registryDefaultPageBuilder(PageBuilder builder) =>
      _pageBuilders.registry(_defaultUrl, builder);

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

  /// Converting arguments to route settings.
  ///
  ThrioRouteSettings argumentsToRouteSettings(Map<String, dynamic> arguments) {
    if ((arguments?.isNotEmpty ?? false) &&
        arguments.containsKey('url') &&
        arguments.containsKey('index')) {
      final urlValue = arguments['url'];
      final url = urlValue is String ? urlValue : null;
      final indexValue = arguments['index'];
      final index = indexValue is int ? indexValue : null;
      final paramsValue = arguments['params'];
      final params = paramsValue is Map
          ? paramsValue.cast<String, dynamic>()
          : <String, dynamic>{};
      final builder = _pageBuilders[url] ?? _pageBuilders[_defaultUrl];
      return ThrioRouteSettings(
        url: url,
        index: index,
        params: params,
        builder: (context) => builder(
          url,
          index: index,
          params: params,
        ),
      );
    }
    return null;
  }
}
