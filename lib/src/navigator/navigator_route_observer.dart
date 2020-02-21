// Copyright (c) 2019/2/21, 20:43:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../logger/thrio_logger.dart';
import '../navigator/navigator_page_route.dart';
import 'navigator_route_settings.dart';

class NavigatorRouteObserver extends NavigatorObserver {
  NavigatorRouteObserver(ThrioChannel channel) : _channel = channel;

  final ThrioChannel _channel;

  final _currentPopRoutes = <NavigatorPageRoute>[];

  final _currentRemoveRoutes = <NavigatorPageRoute>[];

  final pageRoutes = <NavigatorPageRoute>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute is NavigatorPageRoute &&
        previousRoute.willPopCallback != null) {
      pageRoutes.last
          .removeScopedWillPopCallback(previousRoute.willPopCallback);
    }
    if (route is NavigatorPageRoute) {
      ThrioLogger().v('didPush: ${route.settings}');
      if (route.willPopCallback != null) {
        pageRoutes.last.addScopedWillPopCallback(route.willPopCallback);
      }
      pageRoutes.add(route);
      final arguments = <String, dynamic>{
        'url': route.settings.url,
        'index': route.settings.index,
      };
      _channel.invokeMethod<bool>('didPush', arguments);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (previousRoute is NavigatorPageRoute &&
        previousRoute.willPopCallback != null) {
      pageRoutes.last.addScopedWillPopCallback(previousRoute.willPopCallback);
    }
    if (route is NavigatorPageRoute) {
      if (route.willPopCallback != null) {
        pageRoutes.last.removeScopedWillPopCallback(route.willPopCallback);
      }
      pageRoutes.remove(route);
      _currentPopRoutes.add(route);
      if (_currentPopRoutes.length == 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_currentPopRoutes.length == 1) {
            ThrioLogger().v('didPop: ${route.settings}');
            final arguments = <String, dynamic>{
              'url': route.settings.url,
              'index': route.settings.index,
            };
            _channel.invokeMethod<bool>('didPop', arguments);
          } else if (_currentPopRoutes.length > 1) {
            ThrioLogger().v('didPopTo: ${_currentPopRoutes.first.settings}');
            final arguments = <String, dynamic>{
              'url': _currentPopRoutes.last.settings.url,
              'index': _currentPopRoutes.last.settings.index,
            };
            _channel.invokeMethod<bool>('didPopTo', arguments);
          }
          _currentPopRoutes.clear();
        });
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is NavigatorPageRoute) {
      pageRoutes.remove(route);
      _currentRemoveRoutes.add(route);
      if (_currentRemoveRoutes.length == 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_currentRemoveRoutes.length == 1) {
            ThrioLogger().v('didRemove: ${route.settings}');
            final arguments = <String, dynamic>{
              'url': route.settings.url,
              'index': route.settings.index,
            };
            _channel.invokeMethod<bool>('didRemove', arguments);
          } else if (_currentRemoveRoutes.length > 1) {
            ThrioLogger().v('didPopTo: ${_currentRemoveRoutes.last.settings}');
            final arguments = <String, dynamic>{
              'url': _currentRemoveRoutes.last.settings.url,
              'index': _currentRemoveRoutes.last.settings.index,
            };
            _channel.invokeMethod<bool>('didPopTo', arguments);
          }
          _currentRemoveRoutes.clear();
        });
      }
      if (route.willPopCallback != null) {
        pageRoutes.last.removeScopedWillPopCallback(route.willPopCallback);
      }
    }
  }
}