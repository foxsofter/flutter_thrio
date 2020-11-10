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
import 'package:thrio/src/channel/thrio_channel.dart';
import 'package:thrio/src/exception/thrio_exception.dart';
import 'package:thrio/src/registry/registry_map.dart';

import 'navigator_logger.dart';
import 'navigator_observer_manager.dart';
import 'navigator_page_observers.dart';
import 'navigator_route_observers.dart';
import 'navigator_route_receive_channel.dart';
import 'navigator_route_send_channel.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class ThrioNavigatorImplement {
  ThrioNavigatorImplement._(
    this._channel,
    this._sendChannel,
    this._receiveChannel,
    this._observerManager,
    this._pagePoppedResults,
  );

  static ThrioNavigatorImplement _default;

  static TransitionBuilder builder({String entrypoint = 'main'}) {
    if (_default == null) {
      _pageObservers = NavigatorPageObservers(entrypoint);
      _routeObservers = NavigatorRouteObservers(entrypoint);

      final channel = ThrioChannel(channel: '__thrio_app__$entrypoint');
      final sendChannel = NavigatorRouteSendChannel(channel);
      final pagePoppedResults = <String, NavigatorParamsCallback>{};
      final receiveChannel =
          NavigatorRouteReceiveChannel(channel, pagePoppedResults);
      final observerManager = NavigatorObserverManager();
      _default = ThrioNavigatorImplement._(
        channel,
        sendChannel,
        receiveChannel,
        observerManager,
        pagePoppedResults,
      );
      verbose('TransitionBuilder builder');
      // sendChannel.registerUrls(_pageBuilders.keys.toList());
    }

    return (context, child) {
      final navigator = child is Navigator ? child : null;
      if (!navigator.observers.contains(_default._observerManager)) {
        navigator.observers.add(_default._observerManager);
      }
      return NavigatorWidget(
        key: _stateKey ??= GlobalKey<NavigatorWidgetState>(),
        observerManager: _default._observerManager,
        child: navigator,
      );
    };
  }

  static GlobalKey<NavigatorWidgetState> _stateKey;

  static NavigatorWidgetState get navigatorState => _stateKey?.currentState;

  static NavigatorPageObservers _pageObservers;

  static NavigatorRouteObservers _routeObservers;

  static final _pageBuilders = RegistryMap<String, NavigatorPageBuilder>();

  static final _routeTransitionsBuilders =
      RegistryMap<RegExp, RouteTransitionsBuilder>();

  final ThrioChannel _channel;

  final NavigatorRouteSendChannel _sendChannel;

  final NavigatorRouteReceiveChannel _receiveChannel;

  final NavigatorObserverManager _observerManager;

  final Map<String, NavigatorParamsCallback> _pagePoppedResults;

  static void ready() => _default._channel?.invokeMethod<bool>('ready');

  static Future<int> push({
    @required String url,
    params,
    bool animated = true,
    NavigatorParamsCallback poppedResult,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel
        .push(url: url, params: params, animated: animated)
        .then<int>((index) {
      if (poppedResult != null && index != null && index > 0) {
        _default._pagePoppedResults['$index $url'] = poppedResult;
      }
      return index;
    });
  }

  static Future<bool> notify({
    @required String url,
    int index,
    @required String name,
    params,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.notify(
      name: name,
      url: url,
      index: index,
      params: params,
    );
  }

  static Future<bool> pop({
    params,
    bool animated = true,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.pop(params: params, animated: animated);
  }

  static Future<bool> popTo({
    @required String url,
    int index,
    bool animated = true,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.popTo(
      url: url,
      index: index,
      animated: animated,
    );
  }

  static Future<bool> remove({
    @required String url,
    int index,
    bool animated = true,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.remove(
      url: url,
      index: index,
      animated: animated,
    );
  }

  static Future<int> lastIndex({String url}) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.lastIndex(url: url);
  }

  static Future<List<int>> allIndexs({@required String url}) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.allIndexs(url: url);
  }

  static Future<bool> setPopDisabled({
    @required String url,
    int index,
    bool disabled = true,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.setPopDisabled(
      url: url,
      index: index,
      disabled: disabled,
    );
  }

  static Stream onPageNotify({
    @required String url,
    @required int index,
    @required String name,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._receiveChannel.onPageNotify(
      url: url,
      index: index,
      name: name,
    );
  }

  static void hotRestart() {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    _default._channel.invokeMethod<bool>('hotRestart');
  }

  static RegistryMap<String, NavigatorPageBuilder> get pageBuilders =>
      _pageBuilders;

  static NavigatorPageObservers get pageObservers => _pageObservers;

  static NavigatorRouteObservers get routeObservers => _routeObservers;

  static RegistryMap<RegExp, RouteTransitionsBuilder>
      get routeTransitionsBuilders => _routeTransitionsBuilders;
}
