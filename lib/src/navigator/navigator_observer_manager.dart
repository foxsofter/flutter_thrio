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

import '../navigator/navigator_page_observer.dart';
import '../registry/registry_set.dart';
import 'navigator_home.dart';
import 'navigator_logger.dart';
import 'navigator_page_route.dart';
import 'navigator_route_observer.dart';
import 'navigator_route_settings.dart';

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
      final lastRoute = pageRoutes.isNotEmpty ? pageRoutes.last : null;
      pageRoutes.add(route);
      final routeObservers = Set.from(_routeObservers);
      for (final observer in routeObservers) {
        observer.didPush(route.settings, lastRoute?.settings);
      }
      final pageObservers = Set.from(_pageObservers);
      for (final observer in pageObservers) {
        if (lastRoute != null) {
          observer.didDisappear(lastRoute.settings);
        }
        observer.didAppear(route.settings);
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (route is NavigatorPageRoute) {
      pageRoutes.remove(route);
      _currentPopRoutes.add(route);
      if (_currentPopRoutes.length == 1) {
        Future(() {
          final previousRoute = pageRoutes.isEmpty ? null : pageRoutes.last;
          final pageObservers = Set.from(_pageObservers);
          final routeObservers = Set.from(_routeObservers);
          if (_currentPopRoutes.length == 1) {
            for (final observer in pageObservers) {
              observer.didDisappear(route.settings);
              if (previousRoute != null) {
                observer.didAppear(previousRoute.settings);
              }
            }
            if (pageRoutes.last.routeAction == NavigatorRouteAction.popTo) {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              final routeObservers = Set.from(_routeObservers);
              for (final observer in routeObservers) {
                observer.didPopTo(
                  pageRoutes.last.settings,
                  _currentPopRoutes.first.settings,
                );
              }
              final pageObservers = Set.from(_pageObservers);
              for (final observer in pageObservers) {
                observer.didDisappear(_currentPopRoutes.first.settings);
                observer.didAppear(pageRoutes.last.settings);
              }
              pageRoutes.last.routeAction = null;
            }
            if (route.routeAction == NavigatorRouteAction.pop) {
              verbose(
                'didPop: url->${route.settings.url} '
                'index->${route.settings.index} '
                'params:${route.settings.params}',
              );
              for (final observer in routeObservers) {
                observer.didPop(route.settings, previousRoute?.settings);
              }
            }
            if (route.routeAction == NavigatorRouteAction.remove) {
              if (WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed) {
                verbose(
                  'didRemove: url->${route.settings.url} '
                  'index->${route.settings.index} '
                  'params->${route.settings.params}',
                );
                for (final observer in routeObservers) {
                  observer.didRemove(
                    route.settings,
                    previousRoute?.settings,
                  );
                }
              }
            }
          } else if (_currentPopRoutes.length > 1) {
            verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                'index->${pageRoutes.last.settings.index}');
            final routeObservers = Set.from(_routeObservers);
            for (final observer in routeObservers) {
              observer.didPopTo(
                pageRoutes.last.settings,
                _currentPopRoutes.first.settings,
              );
            }
            final pageObservers = Set.from(_pageObservers);
            for (final observer in pageObservers) {
              observer.didDisappear(_currentPopRoutes.first.settings);
              observer.didAppear(pageRoutes.last.settings);
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
      final prevRoute = prevIndex > 0 ? pageRoutes[prevIndex] : null;
      pageRoutes.remove(route);
      _currentRemoveRoutes.add(route);
      if (_currentRemoveRoutes.length == 1) {
        Future(() {
          if (_currentRemoveRoutes.length == 1) {
            if (pageRoutes.last.routeAction == NavigatorRouteAction.popTo) {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              final routeObservers = Set.from(_routeObservers);
              for (final observer in routeObservers) {
                observer.didPopTo(
                  pageRoutes.last.settings,
                  _currentPopRoutes.first.settings,
                );
              }
              final pageObservers = Set.from(_pageObservers);
              for (final observer in pageObservers) {
                observer.didDisappear(_currentPopRoutes.first.settings);
                observer.didAppear(pageRoutes.last.settings);
              }
              pageRoutes.last.routeAction = null;
            } else {
              verbose('didRemove: url->${route.settings.url} '
                  'index->${route.settings.index}');
              final routeObservers = Set.from(_routeObservers);
              for (final observer in routeObservers) {
                observer.didRemove(route.settings, prevRoute?.settings);
              }
            }

            if (isLast) {
              if (WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed) {
                final pageObservers = Set.from(_pageObservers);
                for (final observer in pageObservers) {
                  observer.didDisappear(route.settings);
                  if (prevRoute != null) {
                    observer.didAppear(prevRoute.settings);
                  }
                }
              }
            }
          } else if (_currentRemoveRoutes.length > 1) {
            verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                'index->${pageRoutes.last.settings.index}');
            final observers = Set.from(_routeObservers);
            // remove是最后一个route为之前的active route
            for (final observer in observers) {
              observer.didPopTo(
                pageRoutes.last.settings,
                _currentRemoveRoutes.last.settings,
              );
            }
            final pageObservers = Set.from(_pageObservers);
            for (final observer in pageObservers) {
              observer.didDisappear(_currentRemoveRoutes.last.settings);
              observer.didAppear(pageRoutes.last.settings);
            }
          }
          _currentRemoveRoutes.clear();
        });
      }
    }
  }
}
