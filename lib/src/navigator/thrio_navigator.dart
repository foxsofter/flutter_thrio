// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../registry/registry_map.dart';
import 'navigator_page_route.dart';
import 'navigator_receive_channel.dart';
import 'navigator_route_observer.dart';
import 'navigator_send_channel.dart';
import 'navigator_widget.dart';

class ThrioNavigator {
  ThrioNavigator._();

  static final _default = ThrioNavigator._();

  static TransitionBuilder builder() => (context, child) => NavigatorWidget(
        key: _stateKey,
        observer: NavigatorRouteObserver(_channel),
        child: child is Navigator ? child : null,
      );

  static final _stateKey = GlobalKey<NavigatorWidgetState>();

  static NavigatorWidgetState get navigatorState => _stateKey.currentState;

  static final _channel = ThrioChannel(channel: '__thrio_app__');

  final _sendChannel = NavigatorSendChannel(_channel);

  final _receiveChannel = NavigatorReceiveChannel(_channel);

  final _pageBuilders = RegistryMap<String, NavigatorPageBuilder>();

  /// Push a page with `url` onto `ThrioNavigator`.
  ///
  static Future<bool> push({
    @required String url,
    bool animated = true,
    Map<String, dynamic> params = const {},
  }) =>
      _default._sendChannel.push(
        url: url,
        animated: animated,
        params: params,
      );

  /// Notify a page with `url` and `index`.
  ///
  static Future<bool> notify({
    @required String name,
    @required String url,
    int index = 0,
    Map<String, dynamic> params = const {},
  }) =>
      _default._sendChannel.notify(
        name: name,
        url: url,
        index: index,
        params: params,
      );

  /// Pop a page from `ThrioNavigator`.
  ///
  static Future<bool> pop({bool animated = true}) =>
      _default._sendChannel.pop(animated: animated);

  /// Pop to a page with `url` and `index`.
  ///
  static Future<bool> popTo({
    @required String url,
    int index = 0,
    bool animated = true,
  }) =>
      _default._sendChannel.popTo(
        url: url,
        index: index,
        animated: animated,
      );

  /// Remove a page with `url` and `index` from `ThrioNavigator`.
  ///
  static Future<bool> remove({
    String url = '',
    int index = 0,
    bool animated = true,
  }) =>
      _default._sendChannel.remove(
        url: url,
        index: index,
        animated: animated,
      );

  /// Get the index of the last page.
  ///
  static Future<int> lastIndex({String url}) =>
      _default._sendChannel.lastIndex(url: url);

  /// Get the index of all pages whose url is `url`.
  ///
  static Future<List<int>> allIndex(String index) =>
      _default._sendChannel.allIndex(index);

  /// Set pop disabled with `url` and `index`.
  ///
  static Future<bool> setPopDisabled({
    @required String url,
    int index = 0,
    bool disabled = true,
  }) =>
      _default._sendChannel.setPopDisabled(
        url: url,
        index: index,
        disabled: disabled,
      );

  /// Sets up a broadcast stream for receiving page notify events.
  ///
  /// return value is `params`.
  ///
  static Stream<Map<String, dynamic>> onPageNotifyStream(
    String name,
    String url, {
    int index,
  }) =>
      _default._receiveChannel.onPageNotifyStream(
        name,
        url,
        index: index,
      );

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerDefaultPageBuilder(
    NavigatorPageBuilder builder,
  ) =>
      _default._pageBuilders.registry(Navigator.defaultRouteName, builder);

  /// Register an page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerPageBuilder(
    String url,
    NavigatorPageBuilder builder,
  ) =>
      _default._pageBuilders.registry(url, builder);

  /// Register page builders for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerPageBuilders(
    Map<String, NavigatorPageBuilder> builders,
  ) =>
      _default._pageBuilders.registryAll(builders);

  static NavigatorPageBuilder getPageBuilder(String url) =>
      _default._pageBuilders[url];

  static void hotRestart() => _channel.invokeMethod<bool>('hotRestart');
}
