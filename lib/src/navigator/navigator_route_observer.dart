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
