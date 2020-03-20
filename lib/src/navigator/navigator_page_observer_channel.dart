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

import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../navigator/thrio_navigator_implement.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';

typedef NavigatorPageObserverCallback = void Function(
  NavigatorPageObserver pageObserver,
  RouteSettings settings,
);

class NavigatorPageObserverChannel with NavigatorPageObserver {
  NavigatorPageObserverChannel() {
    _on(
      'onCreate',
      (pageObserver, routeSettings) => pageObserver.onCreate(routeSettings),
    );
    _on(
      'willAppear',
      (pageObserver, routeSettings) => pageObserver.willAppear(routeSettings),
    );
    _on(
      'didAppear',
      (pageObserver, routeSettings) => pageObserver.didAppear(routeSettings),
    );
    _on(
      'willDisappear',
      (pageObserver, routeSettings) =>
          pageObserver.willDisappear(routeSettings),
    );
    _on(
      'didDisappear',
      (pageObserver, routeSettings) => pageObserver.didDisappear(routeSettings),
    );
  }

  final _channel = ThrioChannel(channel: '__thrio_page_channel__');

  @override
  void onCreate(RouteSettings routeSettings) {
    _channel.invokeMethod(
      'onCreate',
      routeSettings.toArguments(),
    );
  }

  @override
  void willAppear(RouteSettings routeSettings) => _channel.invokeMethod(
        'willAppear',
        routeSettings.toArguments(),
      );

  @override
  void didAppear(RouteSettings routeSettings) => _channel.invokeMethod(
        'didAppear',
        routeSettings.toArguments(),
      );

  @override
  void didDisappear(RouteSettings routeSettings) => _channel.invokeMethod(
        'didDisappear',
        routeSettings.toArguments(),
      );

  @override
  void willDisappear(RouteSettings routeSettings) => _channel.invokeMethod(
        'willDisappear',
        routeSettings.toArguments(),
      );

  void _on(String method, NavigatorPageObserverCallback callback) =>
      _channel.registryMethodCall(
          '__on${method[0].toUpperCase() + method.substring(1)}__', (
              [arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final pageObservers = ThrioNavigatorImplement.pageObservers;
        for (final pageObserver in pageObservers) {
          if (pageObserver is NavigatorPageObserverChannel) {
            continue;
          }
          callback(pageObserver, routeSettings);
        }
        return Future.value();
      });
}
