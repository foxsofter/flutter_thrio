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

import '../module/thrio_module.dart';
import 'navigator_logger.dart';
import 'navigator_page_observer.dart';
import 'navigator_route.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorObserverManager extends NavigatorObserver {
  final observers = <NavigatorObserver>[];

  final currentPopRoutes = <NavigatorRoute>[];

  final _currentRemoveRoutes = <NavigatorRoute>[];

  final pageRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    for (final ob in observers) {
      ob.didPush(route, previousRoute);
    }
    if (route is NavigatorRoute) {
      verbose(
        'didPush: url->${route.settings.url} '
        'index->${route.settings.index} ',
      );
      pageRoutes.add(route);
      ThrioNavigatorImplement.shared()
        ..routeChannel.didPush(route.settings)
        ..pageChannel.didAppear(route.settings, NavigatorRouteType.push);
    } else {
      if (!route.isFirst) {
        final lastRoute = pageRoutes.last;
        pageRoutes.add(route);
        if (route is! PopupRoute && lastRoute is NavigatorRoute) {
          final observers = ThrioModule.gets<NavigatorPageObserver>(
            url: lastRoute.settings.url,
          );
          for (final observer in observers) {
            if (observer.settings == null ||
                observer.settings?.name == lastRoute.settings.name) {
              observer.didDisappear(lastRoute.settings);
            }
          }
        }
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Future(() {
      for (final ob in observers) {
        ob.didPop(route, previousRoute);
      }
    });
    if (route is NavigatorRoute) {
      pageRoutes.remove(route);
      currentPopRoutes.add(route);
      if (currentPopRoutes.length == 1) {
        Future(() {
          if (currentPopRoutes.length == 1) {
            if (pageRoutes.last is NavigatorRoute &&
                // ignore: avoid_as
                (pageRoutes.last as NavigatorRoute).routeType ==
                    NavigatorRouteType.popTo) {
              if (pageRoutes.last.settings.url != '/') {
                verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                    'index->${pageRoutes.last.settings.index}');
                ThrioNavigatorImplement.shared()
                  ..routeChannel.didPopTo(pageRoutes.last.settings)
                  ..pageChannel.didAppear(
                      pageRoutes.last.settings, NavigatorRouteType.popTo);
              }
              // ignore: avoid_as
              (pageRoutes.last as NavigatorRoute).routeType = null;
              _currenPopRouteCallbackAndClear(currentPopRoutes);
            } else if (route.routeType == NavigatorRouteType.pop ||
                route.routeType == null) {
              // 这里需要判断 routeType == null 的场景，处理滑动返回需要
              verbose('didPop: url->${route.settings.url} '
                  'index->${route.settings.index} ');
              ThrioNavigatorImplement.shared()
                ..routeChannel.didPop(route.settings)
                ..pageChannel
                    .didDisappear(route.settings, NavigatorRouteType.pop);
              route.routeType = null;
            } else if (route.routeType == NavigatorRouteType.remove) {
              ThrioNavigatorImplement.shared()
                  .routeChannel
                  .didRemove(route.settings);
              verbose(
                'didRemove: url->${route.settings.url} '
                'index->${route.settings.index} ',
              );
              if (WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed) {
                ThrioNavigatorImplement.shared()
                    .pageChannel
                    .didDisappear(route.settings, NavigatorRouteType.remove);
              }
              route.routeType = null;
              _currenPopRouteCallbackAndClear(currentPopRoutes);
            }
          } else if (currentPopRoutes.length > 1) {
            if (pageRoutes.last.settings.url != '/') {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              ThrioNavigatorImplement.shared()
                ..routeChannel.didPopTo(pageRoutes.last.settings)
                ..pageChannel.didAppear(
                    pageRoutes.last.settings, NavigatorRouteType.popTo);
            }
            // ignore: avoid_as
            (pageRoutes.last as NavigatorRoute).routeType = null;
            _currenPopRouteCallbackAndClear(currentPopRoutes);
          }

          // anchor.unloading(pageRoutes.whereType<NavigatorRoute>());
        });
      } else {
        // maybe pop goes here
        // 判断 lenght = 2 是因为 currentPopRoutes 还残留上一个页面的 pop rute
        if (currentPopRoutes.length == 2) {
          final route = currentPopRoutes.last;
          verbose('didPop: url->${route.settings.url} '
              'index->${route.settings.index} ');
          ThrioNavigatorImplement.shared()
            ..routeChannel.didPop(route.settings)
            ..pageChannel.didDisappear(route.settings, NavigatorRouteType.pop);
          route.routeType = null;
        }
      }
    } else {
      pageRoutes.remove(route);
      if (route is! PopupRoute && pageRoutes.last is NavigatorRoute) {
        final observers = ThrioModule.gets<NavigatorPageObserver>(
            url: pageRoutes.last.settings.url);
        for (final observer in observers) {
          if (observer.settings == null ||
              observer.settings?.name == pageRoutes.last.settings.name) {
            observer.didAppear(pageRoutes.last.settings);
          }
        }
      }
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Future(() {
      for (final ob in observers) {
        ob.didRemove(route, previousRoute);
      }
    });
    if (route is NavigatorRoute) {
      pageRoutes.remove(route);
      _currentRemoveRoutes.add(route);
      if (_currentRemoveRoutes.length == 1) {
        Future(() {
          if (_currentRemoveRoutes.length == 1) {
            // ignore: avoid_as
            final lastRoute = pageRoutes.last as NavigatorRoute;
            if (lastRoute.routeType == NavigatorRouteType.popTo) {
              if (pageRoutes.last.settings.url != '/') {
                verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                    'index->${pageRoutes.last.settings.index}');
                ThrioNavigatorImplement.shared()
                  ..routeChannel.didPopTo(pageRoutes.last.settings)
                  ..pageChannel.didAppear(
                    pageRoutes.last.settings,
                    NavigatorRouteType.popTo,
                  );
              }
              lastRoute.routeType = null;
            } else {
              verbose('didRemove: url->${route.settings.url} '
                  'index->${route.settings.index}');
              ThrioNavigatorImplement.shared()
                  .routeChannel
                  .didRemove(route.settings);
            }
          } else if (_currentRemoveRoutes.length > 1) {
            if (pageRoutes.last.settings.url != '/') {
              verbose('didPopTo: url->${pageRoutes.last.settings.url} '
                  'index->${pageRoutes.last.settings.index}');
              // remove是最后一个route为之前的active route
              ThrioNavigatorImplement.shared()
                ..routeChannel.didPopTo(pageRoutes.last.settings)
                ..pageChannel.didAppear(
                  pageRoutes.last.settings,
                  NavigatorRouteType.popTo,
                );
            }
            // ignore: avoid_as
            (pageRoutes.last as NavigatorRoute).routeType = null;
          }

          _currenPopRouteCallbackAndClear(_currentRemoveRoutes);

          // anchor.unloading(pageRoutes.whereType<NavigatorRoute>());
        });
      }
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    Future(() {
      for (final ob in observers) {
        ob.didReplace(newRoute: newRoute, oldRoute: oldRoute);
      }
    });
    if (newRoute is NavigatorRoute && oldRoute is NavigatorRoute) {
      verbose(
        'didReplace: url->${oldRoute.settings.url} index->${oldRoute.settings.index} '
        'newUrl->${newRoute.settings.url} newIndex->${newRoute.settings.index}',
      );
      final idx = pageRoutes.indexOf(oldRoute);
      pageRoutes
        ..remove(oldRoute)
        ..insert(idx, newRoute);
      ThrioNavigatorImplement.shared()
        ..pageChannel
            .didDisappear(oldRoute.settings, NavigatorRouteType.replace)
        ..routeChannel.didReplace(newRoute.settings, oldRoute.settings);
      if (pageRoutes.last.settings.name == newRoute.settings.name) {
        ThrioNavigatorImplement.shared()
            .pageChannel
            .didAppear(newRoute.settings, NavigatorRouteType.replace);
      }
      oldRoute.poppedResult?.call(null);
      oldRoute.poppedResult = null;
    }
  }

  void _currenPopRouteCallbackAndClear(List<NavigatorRoute> routes) {
    for (final route in routes) {
      route.poppedResult?.call(null);
      route.poppedResult = null;
    }
    routes.clear();
  }
}
