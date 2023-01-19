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
import 'navigator_logger.dart';
import 'navigator_route_observer.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

typedef NavigatorRouteObserverCallback = void Function(
  NavigatorRouteObserver observer,
  RouteSettings settings,
);

class NavigatorRouteObserverChannel with NavigatorRouteObserver {
  NavigatorRouteObserverChannel(final String entrypoint)
      : _channel = ThrioChannel(channel: '__thrio_route_channel__$entrypoint') {
    _on(
        'didPush',
        (final observer, final routeSettings) =>
            observer.didPush(routeSettings));
    _on(
        'didPop',
        (final observer, final routeSettings) =>
            observer.didPop(routeSettings));
    _on(
        'didPopTo',
        (final observer, final routeSettings) =>
            observer.didPopTo(routeSettings));
    _on(
        'didRemove',
        (final observer, final routeSettings) =>
            observer.didRemove(routeSettings));
    _onDidReplace();
  }

  final ThrioChannel _channel;

  @override
  void didPush(final RouteSettings routeSettings) =>
      _channel.invokeMethod<bool>(
          'didPush', routeSettings.toArguments()..remove('params'));

  @override
  void didPop(final RouteSettings routeSettings) {
    verbose('didPop: ${routeSettings.name}');
    _channel.invokeMethod<bool>(
        'didPop', routeSettings.toArguments()..remove('params'));
  }

  @override
  void didPopTo(final RouteSettings routeSettings) =>
      _channel.invokeMethod<bool>(
          'didPopTo', routeSettings.toArguments()..remove('params'));

  @override
  void didRemove(final RouteSettings routeSettings) =>
      _channel.invokeMethod<bool>(
          'didRemove', routeSettings.toArguments()..remove('params'));

  @override
  void didReplace(
    final RouteSettings newRouteSettings,
    final RouteSettings oldRouteSettings,
  ) {
    final oldArgs = oldRouteSettings.toArguments()..remove('params');
    final newArgs = newRouteSettings.toArguments()..remove('params');
    _channel.invokeMethod<bool>('didReplace', {
      'oldRouteSettings': oldArgs,
      'newRouteSettings': newArgs,
    });
  }

  void _on(
    final String method,
    final NavigatorRouteObserverCallback callback,
  ) =>
      _channel.registryMethodCall(method, ([final arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings != null) {
          final observers =
              ThrioModule.gets<NavigatorRouteObserver>(url: routeSettings.url);
          for (final observer in observers) {
            callback(observer, routeSettings);
          }
          if (method == 'didPop') {
            final currentPopRoutes =
                ThrioNavigatorImplement.shared().currentPopRoutes;
            if (currentPopRoutes.isNotEmpty &&
                currentPopRoutes.last.settings.name == routeSettings.name) {
              currentPopRoutes.first.poppedResult?.call(null);
            }
            ThrioNavigatorImplement.shared().currentPopRoutes.clear();
          }
        }
        return Future.value();
      });

  void _onDidReplace() =>
      _channel.registryMethodCall('didReplace', ([final arguments]) {
        final newRouteSettings = NavigatorRouteSettings.fromArguments(
            (arguments?['newRouteSettings'] as Map<Object?, Object?>)
                .cast<String, dynamic>());
        final oldRouteSettings = NavigatorRouteSettings.fromArguments(
            (arguments?['oldRouteSettings'] as Map<Object?, Object?>)
                .cast<String, dynamic>());
        if (newRouteSettings != null && oldRouteSettings != null) {
          final observers = <NavigatorRouteObserver>[
            ...ThrioModule.gets<NavigatorRouteObserver>(
                url: newRouteSettings.url),
            ...ThrioModule.gets<NavigatorRouteObserver>(
                url: oldRouteSettings.url),
          ];
          for (final observer in observers) {
            observer.didReplace(newRouteSettings, oldRouteSettings);
          }
        }
        return Future.value();
      });
}
