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

import 'navigator_home.dart';
import 'navigator_logger.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorObserverManager extends NavigatorObserver {
  final _currentPopRoutes = <NavigatorPageRoute>[];

  final _currentRemoveRoutes = <NavigatorPageRoute>[];

  final pageRoutes = <NavigatorPageRoute>[
    NavigatorPageRoute(
        builder: (settings) => const NavigatorHome(),
        settings: const RouteSettings(name: '1 /'))
  ];

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is NavigatorPageRoute) {
      verbose(
        'didPush: url->${route.settings.url} '
        'index->${route.settings.index} '
        'params->${route.settings.params}',
      );
      pageRoutes.add(route);
      ThrioNavigatorImplement.shared().routeObservers.didPush(route.settings);
      ThrioNavigatorImplement.shared()
          .pageObservers
          .didAppear(route.settings, NavigatorRouteAction.push);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is NavigatorPageRoute) {
      pageRoutes.remove(route);
      _currentPopRoutes.add(route);
      if (_currentPopRoutes.length == 1) {
        Future(() {
          if (_currentPopRoutes.length == 1) {
            if (pageRoutes.last.routeAction == NavigatorRouteAction.popTo) {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              ThrioNavigatorImplement.shared()
                  .routeObservers
                  .didPopTo(pageRoutes.last.settings);
              ThrioNavigatorImplement.shared().pageObservers.didAppear(
                    pageRoutes.last.settings,
                    NavigatorRouteAction.popTo,
                  );
              pageRoutes.last.routeAction = null;
            }
            // 这里需要判断 routeAction == null 的场景，处理滑动返回需要
            if (route.routeAction == NavigatorRouteAction.pop ||
                route.routeAction == null) {
              verbose(
                'didPop: url->${route.settings.url} '
                'index->${route.settings.index} '
                'params:${route.settings.params}',
              );
              ThrioNavigatorImplement.shared()
                  .routeObservers
                  .didPop(route.settings);
              ThrioNavigatorImplement.shared()
                  .pageObservers
                  .didDisappear(route.settings, NavigatorRouteAction.pop);
              route.routeAction = null;
            }
            if (route.routeAction == NavigatorRouteAction.remove) {
              if (WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed) {
                verbose(
                  'didRemove: url->${route.settings.url} '
                  'index->${route.settings.index} '
                  'params->${route.settings.params}',
                );
                ThrioNavigatorImplement.shared()
                    .routeObservers
                    .didRemove(route.settings);
                ThrioNavigatorImplement.shared()
                    .pageObservers
                    .didDisappear(route.settings, NavigatorRouteAction.remove);
              }
              route.routeAction = null;
            }
          } else if (_currentPopRoutes.length > 1) {
            verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                'index->${pageRoutes.last.settings.index}');
            ThrioNavigatorImplement.shared()
                .routeObservers
                .didPopTo(pageRoutes.last.settings);
            ThrioNavigatorImplement.shared().pageObservers.didAppear(
                  pageRoutes.last.settings,
                  NavigatorRouteAction.popTo,
                );
            pageRoutes.last.routeAction = null;
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
        Future(() {
          if (_currentRemoveRoutes.length == 1) {
            if (pageRoutes.last.routeAction == NavigatorRouteAction.popTo) {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              ThrioNavigatorImplement.shared()
                  .routeObservers
                  .didPopTo(pageRoutes.last.settings);
              ThrioNavigatorImplement.shared().pageObservers.didAppear(
                    pageRoutes.last.settings,
                    NavigatorRouteAction.popTo,
                  );
              pageRoutes.last.routeAction = null;
            } else {
              verbose('didRemove: url->${route.settings.url} '
                  'index->${route.settings.index}');
              ThrioNavigatorImplement.shared()
                  .routeObservers
                  .didRemove(route.settings);
              ThrioNavigatorImplement.shared().pageObservers.didDisappear(
                    pageRoutes.last.settings,
                    NavigatorRouteAction.remove,
                  );
            }
          } else if (_currentRemoveRoutes.length > 1) {
            verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                'index->${pageRoutes.last.settings.index}');
            // remove是最后一个route为之前的active route
            ThrioNavigatorImplement.shared()
                .routeObservers
                .didPopTo(pageRoutes.last.settings);
            ThrioNavigatorImplement.shared().pageObservers.didAppear(
                  pageRoutes.last.settings,
                  NavigatorRouteAction.popTo,
                );
          }
          _currentRemoveRoutes.clear();
        });
      }
    }
  }
}
