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
import '../exception/thrio_exception.dart';
import '../navigator/navigator_page_observer.dart';
import '../registry/registry_map.dart';
import '../registry/registry_set.dart';
import 'navigator_observer_manager.dart';
import 'navigator_page_observer_channel.dart';
import 'navigator_route_observer.dart';
import 'navigator_route_observer_channel.dart';
import 'navigator_route_receive_channel.dart';
import 'navigator_route_send_channel.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class ThrioNavigatorImplement {
  ThrioNavigatorImplement._({
    ThrioChannel channel,
    NavigatorRouteSendChannel sendChannel,
    NavigatorRouteReceiveChannel receiveChannel,
    Map<String, NavigatorParamsCallback> pagePoppedResults,
    RegistrySet<NavigatorPageObserver> pageObservers,
    RegistrySet<NavigatorRouteObserver> routeObservers,
  })  : _channel = channel,
        _sendChannel = sendChannel,
        _receiveChannel = receiveChannel,
        _pagePoppedResults = pagePoppedResults,
        _pageObservers = pageObservers,
        _routeObservers = routeObservers;

  static ThrioNavigatorImplement _default;

  static TransitionBuilder builder({String entrypoint = ''}) {
    final channel = ThrioChannel(channel: '__thrio_app__$entrypoint');
    final sendChannel = NavigatorRouteSendChannel(channel);
    final pagePoppedResults = <String, NavigatorParamsCallback>{};
    final receiveChannel =
        NavigatorRouteReceiveChannel(channel, pagePoppedResults);
    final pageObservers = RegistrySet<NavigatorPageObserver>()
      ..registry(NavigatorPageObserverChannel());
    final routeObservers = RegistrySet<NavigatorRouteObserver>()
      ..registry(NavigatorRouteObserverChannel());
    _default = ThrioNavigatorImplement._(
      channel: channel,
      sendChannel: sendChannel,
      receiveChannel: receiveChannel,
      pagePoppedResults: pagePoppedResults,
      pageObservers: pageObservers,
      routeObservers: routeObservers,
    );
    sendChannel.registerUrls(_pageBuilders.keys.toList());

    return (context, child) => NavigatorWidget(
          key: _stateKey ??= GlobalKey<NavigatorWidgetState>(),
          observerManager: NavigatorObserverManager(
            pageObservers: _default._pageObservers,
            routeObservers: _default._routeObservers,
          ),
          child: child is Navigator ? child : null,
        );
  }

  static GlobalKey<NavigatorWidgetState> _stateKey;

  static NavigatorWidgetState get navigatorState => _stateKey?.currentState;

  final ThrioChannel _channel;

  final NavigatorRouteSendChannel _sendChannel;

  final NavigatorRouteReceiveChannel _receiveChannel;

  final Map<String, NavigatorParamsCallback> _pagePoppedResults;

  final RegistrySet<NavigatorPageObserver> _pageObservers;

  final RegistrySet<NavigatorRouteObserver> _routeObservers;

  static final _pageBuilders = RegistryMap<String, NavigatorPageBuilder>();

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
        _default._pagePoppedResults['$url.$index'] = poppedResult;
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

  static Future<List<int>> allIndex({@required String url}) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.allIndex(url: url);
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

  static VoidCallback registerDefaultPageBuilder(
    NavigatorPageBuilder builder,
  ) =>
      _pageBuilders.registry(Navigator.defaultRouteName, builder);

  static VoidCallback registerPageBuilder(
    String url,
    NavigatorPageBuilder builder,
  ) {
    _default?._sendChannel?.registerUrls([url]);
    final callback = _pageBuilders.registry(url, builder);
    return () {
      callback();
      _default?._sendChannel?.unregisterUrls([url]);
    };
  }

  static VoidCallback registerPageBuilders(
    Map<String, NavigatorPageBuilder> builders,
  ) {
    _default?._sendChannel?.registerUrls(builders.keys.toList());
    final callback = _pageBuilders.registryAll(builders);
    return () {
      callback();
      _default?._sendChannel?.unregisterUrls(builders.keys.toList());
    };
  }

  static NavigatorPageBuilder getPageBuilder(String url) => _pageBuilders[url];

  static RegistrySet<NavigatorPageObserver> get pageObservers =>
      _default?._pageObservers;

  static RegistrySet<NavigatorRouteObserver> get routeObservers =>
      _default?._routeObservers;

  static VoidCallback registerPageObserver(
          NavigatorPageObserver pageObserver) =>
      _default._pageObservers.registry(pageObserver);

  static VoidCallback registerRouteObserver(
          NavigatorRouteObserver routeObserver) =>
      _default._routeObservers.registry(routeObserver);
}
