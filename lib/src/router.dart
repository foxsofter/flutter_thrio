// Copyright (c) 2019/11/25, 19:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'extension/stateful_widget.dart';
import 'registry/registry_map.dart';
import 'registry/registry_set.dart';
import 'router_channel.dart';
import 'router_container.dart';
import 'router_navigator.dart';
import 'router_predicate.dart';
import 'router_route_settings.dart';
import 'thrio_types.dart';

/// A class that provides push, pop, popTo and notify page functions.
///
class Router {
  factory Router() => _default;

  Router._();

  static final _default = Router._();

  RouterNavigator _navigator;

  final _predicates = RegistrySet<RouterPredicate>();

  final _pageBuilders = RegistryMap<String, PageBuilder>();

  final _defaultUrl = '/';

  final _channel = RouterChannel();

  /// Assigned when the `builder` method is called.
  ///
  RouterNavigatorState get navigatorState =>
      _navigator.tryStateOf<RouterNavigatorState>();

  /// Get current container.
  ///
  RouterContainer get current =>
      _navigator.tryStateOf<RouterNavigatorState>()?.current;

  TransitionBuilder builder({
    TransitionBuilder builder,
    RouterRouteFactory willPush,
    RouterRouteFactory didPush,
  }) {
    if (Platform.isAndroid) {
      _channel.invokeMapMethod<String, dynamic>('pageOnStart').then((result) {
        final routeSettings = argumentsToRouteSettings(result);
        routeSettings ??
            _navigator
                .tryStateOf<RouterNavigatorState>()
                ?.activate(routeSettings);
      });
    }
    return (context, child) {
      assert(child is Navigator, 'child must be a Navigator.');

      _navigator = RouterNavigator(
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
  }) async {
    if (!await _canNotify(
      url,
      index: index,
      params: params,
    )) {
      return false;
    }

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
  }) async {
    if (!await _canPop(url, index, animated)) {
      return false;
    }

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
  }) async {
    if (!await _canPopTo(url, index, animated)) {
      return false;
    }

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
  }) async {
    if (!await _canPush(url, animated, params)) {
      return false;
    }

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

  /// Register an predicate for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  VoidCallback registryPredicate(RouterPredicate predicate) =>
      _predicates.registry(predicate);

  /// Converting arguments to route settings.
  ///
  RouterRouteSettings argumentsToRouteSettings(Map<String, dynamic> arguments) {
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
      return RouterRouteSettings(
        url: url,
        index: index,
        params: params,
        builder: (context) => builder(url, index, params),
      );
    }
    return null;
  }

  Future<bool> _canNotify(
    String url, {
    int index = 0,
    Map<String, dynamic> params = const {},
  }) async {
    var canNotify = true;
    for (final it in _predicates) {
      final result = await it.canNotify(
        url,
        index: index,
        params: params,
      );
      if (canNotify) {
        canNotify = result;
      }
    }
    return canNotify;
  }

  Future<bool> _canPop(
    String url,
    int index,
    bool animated,
  ) async {
    var canPop = true;
    for (final it in _predicates) {
      final result = await it.canPop(
        url,
        index: index,
      );
      if (canPop) {
        canPop = result;
      }
    }
    return canPop;
  }

  Future<bool> _canPopTo(
    String url,
    int index,
    bool animated,
  ) async {
    var canPopTo = true;
    for (final it in _predicates) {
      final result = await it.canPopTo(
        url,
        index: index,
      );
      if (canPopTo) {
        canPopTo = result;
      }
    }
    return canPopTo;
  }

  Future<bool> _canPush(
    String url,
    bool animated,
    Map<String, dynamic> params,
  ) async {
    var canPush = true;
    for (final it in _predicates) {
      final result = await it.canPush(
        url,
        params: params,
      );
      if (canPush) {
        canPush = result;
      }
    }
    return canPush;
  }
}
