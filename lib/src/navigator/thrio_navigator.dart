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
import 'package:thrio/src/exception/thrio_exception.dart';
import 'package:thrio/thrio.dart';

import '../channel/thrio_channel.dart';
import '../registry/registry_map.dart';
import 'navigator_receive_channel.dart';
import 'navigator_route_observer.dart';
import 'navigator_send_channel.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class ThrioNavigator {
  ThrioNavigator._({
    ThrioChannel channel,
    NavigatorSendChannel sendChannel,
    NavigatorReceiveChannel receiveChannel,
    Map<String, NavigatorParamsCallback> pagePoppedResults,
  })  : _channel = channel,
        _sendChannel = sendChannel,
        _receiveChannel = receiveChannel,
        _pagePoppedResults = pagePoppedResults;

  static ThrioNavigator _default;

  static TransitionBuilder builder({String entrypoint = ''}) {
    final channel = ThrioChannel(channel: '__thrio_app__$entrypoint');
    final sendChannel = NavigatorSendChannel(channel);
    final pagePoppedResults = <String, NavigatorParamsCallback>{};
    final receiveChannel = NavigatorReceiveChannel(channel, pagePoppedResults);
    _default = ThrioNavigator._(
      channel: channel,
      sendChannel: sendChannel,
      receiveChannel: receiveChannel,
      pagePoppedResults: pagePoppedResults,
    );
    sendChannel.registerUrls(_pageBuilders.keys.toList());

    return (context, child) => NavigatorWidget(
          key: _stateKey ??= GlobalKey<NavigatorWidgetState>(),
          observer: NavigatorRouteObserver(channel),
          child: child is Navigator ? child : null,
        );
  }

  static GlobalKey<NavigatorWidgetState> _stateKey;

  static NavigatorWidgetState get navigatorState => _stateKey?.currentState;

  final ThrioChannel _channel;

  final NavigatorSendChannel _sendChannel;

  final NavigatorReceiveChannel _receiveChannel;

  final Map<String, NavigatorParamsCallback> _pagePoppedResults;

  static final _pageBuilders = RegistryMap<String, NavigatorPageBuilder>();

  /// Sent when the navigation stack can be pushed.
  ///
  /// Do not call this method.
  ///
  static void ready() => _default._channel?.invokeMethod<bool>('ready');

  /// Push the page onto the navigation stack.
  ///
  /// If a native page builder exists for the `url`, open the native page,
  /// otherwise open the flutter page.
  ///
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

  /// Send a notification to the page.
  ///
  /// Notifications will be triggered when the page enters the foreground.
  /// Notifications with the same `name` will be overwritten.
  ///
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

  /// Pop a page from the navigation stack.
  ///
  static Future<bool> pop({
    params,
    bool animated = true,
  }) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.pop(params: params, animated: animated);
  }

  /// Pop the page in the navigation stack until the page with `url`.
  ///
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

  /// Remove the page with `url` in the navigation stack.
  ///
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

  /// Returns the index of the page that was last pushed to the navigation
  /// stack.
  ///
  static Future<int> lastIndex({String url}) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.lastIndex(url: url);
  }

  /// Returns all index of the page with `url` in the navigation stack.
  ///
  static Future<List<int>> allIndex({@required String url}) {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    return _default._sendChannel.allIndex(url: url);
  }

  /// Setting the page with `url` and `index` cannot be poped..
  ///
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

  /// Sets up a broadcast stream for receiving page notify events.
  ///
  /// return value is `params`.
  ///
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

  /// Send on hot restart.
  ///
  static void hotRestart() {
    if (_default == null) {
      throw ThrioException('Must call the `builder` method first');
    }
    _default._channel.invokeMethod<bool>('hotRestart');
  }

  /// Register default page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  static VoidCallback registerDefaultPageBuilder(
    NavigatorPageBuilder builder,
  ) =>
      _pageBuilders.registry(Navigator.defaultRouteName, builder);

  /// Register an page builder for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
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

  /// Register page builders for the router.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
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
}
