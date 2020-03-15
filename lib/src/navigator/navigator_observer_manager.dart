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

import '../logger/thrio_logger.dart';
import '../navigator/navigator_page_observer.dart';
import '../registry/registry_set.dart';
import 'navigator_page_route.dart';
import 'navigator_route_observer.dart';

class NavigatorObserverManager extends NavigatorObserver {
  NavigatorObserverManager({
    RegistrySet<NavigatorRouteObserver> routeObservers,
    RegistrySet<NavigatorPageObserver> pageObservers,
  })  : _routeObservers = routeObservers,
        _pageObservers = pageObservers;

  final RegistrySet<NavigatorRouteObserver> _routeObservers;

  final RegistrySet<NavigatorPageObserver> _pageObservers;

  final _currentPopRoutes = <NavigatorPageRoute>[];

  final _currentRemoveRoutes = <NavigatorPageRoute>[];

  final pageRoutes = <NavigatorPageRoute>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is NavigatorPageRoute) {
      ThrioLogger().v('didPush: ${route.settings}');
      final lastRoute = pageRoutes.isNotEmpty ? pageRoutes.last : null;
      pageRoutes.add(route);
      final routeObservers = Set.from(_routeObservers);
      for (final observer in routeObservers) {
        Future(() => observer.didPush(route, lastRoute));
      }
      final pageObservers = Set.from(_pageObservers);
      for (final observer in pageObservers) {
        if (lastRoute != null) {
          Future(() => observer.didDisappear(lastRoute));
        }
        Future(() => observer.didAppear(route));
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is NavigatorPageRoute) {
      pageRoutes.remove(route);
      _currentPopRoutes.add(route);
      if (_currentPopRoutes.length == 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_currentPopRoutes.length == 1) {
            ThrioLogger().v('didPop: ${route.settings}');
            final observers = Set.from(_routeObservers);
            for (final observer in observers) {
              Future(() => observer.didPop(route, pageRoutes.last));
            }
            final pageObservers = Set.from(_pageObservers);
            for (final observer in pageObservers) {
              Future(() => observer.didDisappear(route));
              Future(() => observer.didAppear(pageRoutes.last));
            }
          } else if (_currentPopRoutes.length > 1) {
            ThrioLogger().v('didPopTo: ${pageRoutes.last.settings}');
            final routeObservers = Set.from(_routeObservers);
            for (final observer in routeObservers) {
              Future(() => observer.didPopTo(
                    pageRoutes.last,
                    _currentPopRoutes.first,
                  ));
            }
            final pageObservers = Set.from(_pageObservers);
            for (final observer in pageObservers) {
              Future(() => observer.didDisappear(_currentPopRoutes.first));
              Future(() => observer.didAppear(pageRoutes.last));
            }
          }
          _currentPopRoutes.clear();
        });
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is NavigatorPageRoute) {
      final isLast = route == pageRoutes.last;
      final prevIndex = pageRoutes.indexOf(route) - 1;
      final prevRoute = pageRoutes[prevIndex];
      pageRoutes.remove(route);
      _currentRemoveRoutes.add(route);
      if (_currentRemoveRoutes.length == 1) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_currentRemoveRoutes.length == 1) {
            ThrioLogger().v('didRemove: ${route.settings}');
            final routeObservers = Set.from(_routeObservers);
            for (final observer in routeObservers) {
              Future(() => observer.didRemove(route, prevRoute));
            }
            if (isLast) {
              final pageObservers = Set.from(_pageObservers);
              for (final observer in pageObservers) {
                Future(() => observer.didDisappear(route));
                Future(() => observer.didAppear(prevRoute));
              }
            }
          } else if (_currentRemoveRoutes.length > 1) {
            ThrioLogger().v('didPopTo: ${pageRoutes.last.settings}');
            final observers = Set.from(_routeObservers);
            // remove是最后一个route为之前的active route
            for (final observer in observers) {
              Future(() => observer.didPopTo(
                    pageRoutes.last,
                    _currentRemoveRoutes.last,
                  ));
            }
            final pageObservers = Set.from(_pageObservers);
            for (final observer in pageObservers) {
              Future(() => observer.didDisappear(_currentRemoveRoutes.last));
              Future(() => observer.didAppear(pageRoutes.last));
            }
          }
          _currentRemoveRoutes.clear();
        });
      }
    }
  }
}
