// Copyright (c) 2019/11/25, 21:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thrio_router/src/router_route_settings.dart';

import 'router.dart';
import 'router_navigator_observer.dart';
import 'router_route.dart';

class RouterContainer extends Navigator {
  factory RouterContainer({
    @required Navigator navigator,
    @required RouterRouteSettings routeSettings,
    List<NavigatorObserver> observers,
  }) =>
      RouterContainer._(
        key: GlobalKey<RouterContainerState>(),
        routeSettings: routeSettings,
        initialRoute: navigator.initialRoute,
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return RouterRoute(
              settings: settings,
              routeSettings: routeSettings,
            );
          }
          return navigator.onGenerateRoute(settings);
        },
        onUnknownRoute: navigator.onUnknownRoute,
        observers: observers,
      );

  factory RouterContainer.copyWith({
    @required Navigator navigator,
    RouterRouteSettings routeSettings,
  }) =>
      RouterContainer._(
        key: GlobalKey<RouterContainerState>(),
        routeSettings: routeSettings,
        initialRoute: navigator.initialRoute,
        onGenerateRoute: navigator.onGenerateRoute,
        onUnknownRoute: navigator.onUnknownRoute,
        observers: navigator.observers,
      );

  const RouterContainer._(
      {GlobalKey<RouterContainerState> key,
      this.routeSettings = const RouterRouteSettings(),
      String initialRoute,
      RouteFactory onGenerateRoute,
      RouteFactory onUnknownRoute,
      List<NavigatorObserver> observers})
      : super(
            key: key,
            initialRoute: initialRoute,
            onGenerateRoute: onGenerateRoute,
            onUnknownRoute: onUnknownRoute,
            observers: observers);

  final RouterRouteSettings routeSettings;

  @override
  StatefulElement createElement() => RouterContainerElement(this);

  @override
  NavigatorState createState() => RouterContainerState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) =>
      'RouterContainer:${routeSettings.url},${routeSettings.index}';
}

class RouterContainerElement extends StatefulElement {
  RouterContainerElement(StatefulWidget widget) : super(widget);
}

class RouterContainerState extends NavigatorState {
  final _routeHistory = <Route>[];

  RouterContainer get containerWidget {
    final widget = super.widget;
    return widget is RouterContainer ? widget : null;
  }

  Future<bool> backPressed() => maybePop();

  @override
  void didUpdateWidget(Navigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    _findRouterNavigatorObserver(oldWidget)?.clear();
  }

  @override
  void dispose() {
    _findRouterNavigatorObserver(widget)?.clear();
    _routeHistory.clear();
    super.dispose();
  }

  @override
  Future<bool> maybePop<T extends Object>([T result]) async {
    if (mounted) {
      final route = _routeHistory.last;
      final disposition = await route.willPop();
      switch (disposition) {
        case RoutePopDisposition.pop:
          pop(result);
          return true;
        case RoutePopDisposition.doNotPop:
          return false;
        case RoutePopDisposition.bubble:
          pop(result);
          return true;
      }
    }
    return false;
  }

  @override
  bool pop<T extends Object>([T result]) {
    if (_routeHistory.isNotEmpty) {
      _routeHistory.removeLast();
    }

    if (canPop()) {
      return super.pop(result);
    }
    Router().pop(
      containerWidget.routeSettings.url,
      index: containerWidget.routeSettings.index,
    );

    return false;
  }

  @override
  Future<T> push<T extends Object>(Route<T> route) {
    Route<T> newRoute;

    if (Router().navigatorState?.onWillPushRoute != null) {
      newRoute = Router()
          .navigatorState
          .onWillPushRoute<T>(containerWidget.routeSettings);
    }

    final future = super.push(newRoute ?? route);

    _routeHistory.add(route);

    if (Router().navigatorState?.onDidPushRoute != null) {
      Router().navigatorState.onDidPushRoute(containerWidget.routeSettings);
    }

    return future;
  }

  RouterNavigatorObserver _findRouterNavigatorObserver(Navigator navigator) {
    for (final observer in navigator.observers) {
      if (observer is RouterNavigatorObserver) {
        return observer;
      }
    }
    return null;
  }
}
