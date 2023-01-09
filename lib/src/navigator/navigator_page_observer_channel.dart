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
import '../module/thrio_module.dart';
import 'navigator_page_observer.dart';
import 'navigator_route.dart';
import 'navigator_route_settings.dart';

typedef NavigatorPageObserverCallback = void Function(
    NavigatorPageObserver observer, RouteSettings settings);

class NavigatorPageObserverChannel {
  NavigatorPageObserverChannel(final String entrypoint)
      : _channel = ThrioChannel(channel: '__thrio_page_channel__$entrypoint') {
    _on(
        'willAppear',
        (final observer, final routeSettings) =>
            observer.willAppear(routeSettings));
    _on('didAppear', (final observer, final routeSettings) {
      observer.didAppear(routeSettings);
    });
    _on(
        'willDisappear',
        (final observer, final routeSettings) =>
            observer.willDisappear(routeSettings));
    _on(
        'didDisappear',
        (final observer, final routeSettings) =>
            observer.didDisappear(routeSettings));
  }

  final ThrioChannel _channel;

  void willAppear(
    final RouteSettings routeSettings,
    final NavigatorRouteType routeType,
  ) {
    final arguments = routeSettings.toArguments()..remove('params');
    arguments['routeType'] = routeType.toString().split('.').last;
    _channel.invokeMethod<dynamic>('willAppear', arguments);
  }

  void didAppear(
    final RouteSettings routeSettings,
    final NavigatorRouteType routeType,
  ) {
    final arguments = routeSettings.toArguments()..remove('params');
    arguments['routeType'] = routeType.toString().split('.').last;
    _channel.invokeMethod<dynamic>('didAppear', arguments);
  }

  void willDisappear(
    final RouteSettings routeSettings,
    final NavigatorRouteType routeType,
  ) {
    final arguments = routeSettings.toArguments()..remove('params');
    arguments['routeType'] = routeType.toString().split('.').last;
    _channel.invokeMethod<dynamic>('willDisappear', arguments);
  }

  void didDisappear(
    final RouteSettings routeSettings,
    final NavigatorRouteType routeType,
  ) {
    final arguments = routeSettings.toArguments()..remove('params');
    arguments['routeType'] = routeType.toString().split('.').last;
    _channel.invokeMethod<dynamic>('didDisappear', arguments);
  }

  void _on(final String method, final NavigatorPageObserverCallback callback) =>
      _channel.registryMethodCall(method, ([final arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings != null) {
          final observers =
              ThrioModule.gets<NavigatorPageObserver>(url: routeSettings.url);
          for (final observer in observers) {
            if (observer.settings == null ||
                observer.settings?.name == routeSettings.name) {
              callback(observer, routeSettings);
            }
          }
        }
        return Future.value();
      });
}
