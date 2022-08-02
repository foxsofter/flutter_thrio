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

import '../module/module_anchor.dart';
import '../module/thrio_module.dart';
import 'navigator_home.dart';
import 'navigator_logger.dart';
import 'navigator_page_observer.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorObserverManager extends NavigatorObserver {
  final _currentPopRoutes = <NavigatorPageRoute>[];

  final _currentRemoveRoutes = <NavigatorPageRoute>[];

  final pageRoutes = <Route>[
    NavigatorPageRoute(
        builder: (settings) => const NavigatorHome(), settings: const RouteSettings(name: '1 /'))
  ];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is NavigatorPageRoute) {
      verbose(
        'didPush: url->${route.settings.url} '
        'index->${route.settings.index} ',
      );
      pageRoutes.add(route);
      ThrioNavigatorImplement.shared()
        ..routeChannel.didPush(route.settings)
        ..pageChannel.didAppear(route.settings, NavigatorRouteAction.push);
    } else {
      if (!route.isFirst) {
        final lastRoute = pageRoutes.last;
        pageRoutes.add(route);
        if (route is! PopupRoute && lastRoute is NavigatorPageRoute) {
          final observers = ThrioModule.gets<NavigatorPageObserver>(url: lastRoute.settings.url!);
          for (final observer in observers) {
            observer.didDisappear(lastRoute.settings);
          }
        }
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is NavigatorPageRoute) {
      pageRoutes.remove(route);
      _currentPopRoutes.add(route);
      if (_currentPopRoutes.length == 1) {
        Future(() {
          if (_currentPopRoutes.length == 1) {
            if (pageRoutes.last is NavigatorPageRoute &&
                // ignore: avoid_as
                (pageRoutes.last as NavigatorPageRoute).routeAction == NavigatorRouteAction.popTo) {
              if (pageRoutes.last.settings.url != '/') {
                verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                    'index->${pageRoutes.last.settings.index}');
                ThrioNavigatorImplement.shared()
                  ..routeChannel.didPopTo(pageRoutes.last.settings)
                  ..pageChannel.didAppear(pageRoutes.last.settings, NavigatorRouteAction.popTo);
              }
              // ignore: avoid_as
              (pageRoutes.last as NavigatorPageRoute).routeAction = null;
            } else if (route.routeAction == NavigatorRouteAction.pop || route.routeAction == null) {
              // 这里需要判断 routeAction == null 的场景，处理滑动返回需要
              verbose('didPop: url->${route.settings.url} '
                  'index->${route.settings.index} ');
              ThrioNavigatorImplement.shared()
                ..routeChannel.didPop(route.settings)
                ..pageChannel.didDisappear(route.settings, NavigatorRouteAction.pop);
              route.routeAction = null;
            } else if (route.routeAction == NavigatorRouteAction.remove) {
              if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
                verbose(
                  'didRemove: url->${route.settings.url} '
                  'index->${route.settings.index} ',
                );
                ThrioNavigatorImplement.shared()
                  ..routeChannel.didRemove(route.settings)
                  ..pageChannel.didDisappear(route.settings, NavigatorRouteAction.remove);
              }
              route.routeAction = null;
            }
          } else if (_currentPopRoutes.length > 1) {
            if (pageRoutes.last.settings.url != '/') {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              ThrioNavigatorImplement.shared()
                ..routeChannel.didPopTo(pageRoutes.last.settings)
                ..pageChannel.didAppear(pageRoutes.last.settings, NavigatorRouteAction.popTo);
            }
            // ignore: avoid_as
            (pageRoutes.last as NavigatorPageRoute).routeAction = null;
          }
          _currentPopRoutes.clear();

          anchor.unloading(pageRoutes.whereType<NavigatorPageRoute>());
        });
      }
    } else {
      pageRoutes.remove(route);
      if (route is! PopupRoute && pageRoutes.last is NavigatorPageRoute) {
        final observers =
            ThrioModule.gets<NavigatorPageObserver>(url: pageRoutes.last.settings.url!);
        for (final observer in observers) {
          observer.didAppear(pageRoutes.last.settings);
        }
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is NavigatorPageRoute) {
      pageRoutes.remove(route);
      _currentRemoveRoutes.add(route);
      if (_currentRemoveRoutes.length == 1) {
        Future(() {
          if (_currentRemoveRoutes.length == 1) {
            // ignore: avoid_as
            final lastRoute = pageRoutes.last as NavigatorPageRoute;
            if (lastRoute.routeAction == NavigatorRouteAction.popTo) {
              if (pageRoutes.last.settings.url != '/') {
                verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                    'index->${pageRoutes.last.settings.index}');
                ThrioNavigatorImplement.shared()
                  ..routeChannel.didPopTo(pageRoutes.last.settings)
                  ..pageChannel.didAppear(pageRoutes.last.settings, NavigatorRouteAction.popTo);
              }
              lastRoute.routeAction = null;
            } else {
              verbose('didRemove: url->${route.settings.url} '
                  'index->${route.settings.index}');
              ThrioNavigatorImplement.shared()
                ..routeChannel.didRemove(route.settings)
                ..pageChannel.didDisappear(pageRoutes.last.settings, NavigatorRouteAction.remove);
            }
          } else if (_currentRemoveRoutes.length > 1) {
            if (pageRoutes.last.settings.url != '/') {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              // remove是最后一个route为之前的active route
              ThrioNavigatorImplement.shared()
                ..routeChannel.didPopTo(pageRoutes.last.settings)
                ..pageChannel.didAppear(pageRoutes.last.settings, NavigatorRouteAction.popTo);
            }
            // ignore: avoid_as
            (pageRoutes.last as NavigatorPageRoute).routeAction = null;
          }
          _currentRemoveRoutes.clear();

          anchor.unloading(pageRoutes.whereType<NavigatorPageRoute>());
        });
      }
    }
  }
}
