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
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../module/module_context.dart';
import '../registry/registry_map.dart';
import 'navigator_logger.dart';
import 'navigator_observer_manager.dart';
import 'navigator_page_observers.dart';
import 'navigator_route_observers.dart';
import 'navigator_route_receive_channel.dart';
import 'navigator_route_send_channel.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class ThrioNavigatorImplement {
  factory ThrioNavigatorImplement.shared() =>
      _default ??= ThrioNavigatorImplement._();

  ThrioNavigatorImplement._();

  static ThrioNavigatorImplement _default;

  void init(ModuleContext moduleContext) {
    _pageObservers = NavigatorPageObservers(moduleContext.entrypoint);
    _routeObservers = NavigatorRouteObservers(moduleContext.entrypoint);
    _channel =
        ThrioChannel(channel: '__thrio_app__${moduleContext.entrypoint}');
    _sendChannel = NavigatorRouteSendChannel(_channel);
    _receiveChannel = NavigatorRouteReceiveChannel(
      _channel,
      _pagePoppedResults,
    );
    _observerManager = NavigatorObserverManager();

    verbose('TransitionBuilder builder');
    // sendChannel.registerUrls(_pageBuilders.keys.toList());
  }

  TransitionBuilder get builder => (context, child) {
        final navigator = child is Navigator ? child : null;
        if (!navigator.observers.contains(_observerManager)) {
          navigator.observers.add(_observerManager);
        }
        return NavigatorWidget(
          key: _stateKey ??= GlobalKey<NavigatorWidgetState>(),
          moduleContext: _moduleContext,
          observerManager: _observerManager,
          child: navigator,
        );
      };

  ModuleContext _moduleContext;

  GlobalKey<NavigatorWidgetState> _stateKey;

  NavigatorWidgetState get navigatorState => _stateKey?.currentState;

  NavigatorPageObservers _pageObservers;

  NavigatorRouteObservers _routeObservers;

  final _pageBuilders = RegistryMap<String, NavigatorPageBuilder>();

  final _pagePoppedResults = <String, NavigatorParamsCallback>{};

  final _routeTransitionsBuilders =
      RegistryMap<RegExp, RouteTransitionsBuilder>();

  ThrioChannel _channel;

  NavigatorRouteSendChannel _sendChannel;

  NavigatorRouteReceiveChannel _receiveChannel;

  NavigatorObserverManager _observerManager;

  void ready() => _channel?.invokeMethod<bool>('ready');

  Future<int> push({
    @required String url,
    dynamic params,
    bool animated = true,
    NavigatorParamsCallback poppedResult,
  }) =>
      _sendChannel
          ?.push(url: url, params: params, animated: animated)
          ?.then<int>((index) {
        if (poppedResult != null && index != null && index > 0) {
          _pagePoppedResults['$index $url'] = poppedResult;
        }
        return index;
      });

  Future<bool> notify({
    @required String url,
    int index,
    @required String name,
    dynamic params,
  }) =>
      _sendChannel?.notify(
        name: name,
        url: url,
        index: index,
        params: params,
      );

  Future<bool> pop({
    dynamic params,
    bool animated = true,
  }) =>
      _sendChannel?.pop(params: params, animated: animated);

  Future<bool> popTo({
    @required String url,
    int index,
    bool animated = true,
  }) =>
      _sendChannel?.popTo(
        url: url,
        index: index,
        animated: animated,
      );

  Future<bool> remove({
    @required String url,
    int index,
    bool animated = true,
  }) =>
      _sendChannel?.remove(
        url: url,
        index: index,
        animated: animated,
      );

  Future<int> lastIndex({String url}) => _sendChannel?.lastIndex(url: url);

  Future<List<int>> allIndexs({@required String url}) =>
      _sendChannel?.allIndexs(url: url);

  Future<bool> setPopDisabled({
    @required String url,
    int index,
    bool disabled = true,
  }) =>
      _sendChannel?.setPopDisabled(
        url: url,
        index: index,
        disabled: disabled,
      );

  Stream onPageNotify({
    @required String url,
    @required int index,
    @required String name,
  }) =>
      _receiveChannel?.onPageNotify(
        url: url,
        index: index,
        name: name,
      );

  void hotRestart() {
    _channel?.invokeMethod<bool>('hotRestart');
  }

  RegistryMap<String, NavigatorPageBuilder> get pageBuilders => _pageBuilders;

  NavigatorPageObservers get pageObservers => _pageObservers;

  NavigatorRouteObservers get routeObservers => _routeObservers;

  RegistryMap<RegExp, RouteTransitionsBuilder> get routeTransitionsBuilders =>
      _routeTransitionsBuilders;
}
