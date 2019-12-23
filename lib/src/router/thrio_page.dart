// Copyright (c) 2019/11/25, 21:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'thrio_navigator_observer.dart';
import 'thrio_route.dart' as router;
import 'thrio_route_settings.dart';
import 'thrio_router.dart';

class ThrioPage extends Navigator {
  factory ThrioPage({
    @required Navigator navigator,
    @required ThrioRouteSettings routeSettings,
    List<NavigatorObserver> observers,
  }) =>
      ThrioPage._(
        key: GlobalKey<ThrioPageState>(),
        routeSettings: routeSettings,
        initialRoute: navigator.initialRoute,
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return router.ThrioRoute(
              settings: settings,
              routeSettings: routeSettings,
            );
          }
          return navigator.onGenerateRoute(settings);
        },
        onUnknownRoute: navigator.onUnknownRoute,
        observers: observers,
      );

  factory ThrioPage.copyWith({
    @required Navigator navigator,
    ThrioRouteSettings routeSettings,
  }) =>
      ThrioPage._(
        key: GlobalKey<ThrioPageState>(),
        routeSettings: routeSettings,
        initialRoute: navigator.initialRoute,
        onGenerateRoute: navigator.onGenerateRoute,
        onUnknownRoute: navigator.onUnknownRoute,
        observers: navigator.observers,
      );

  const ThrioPage._(
      {GlobalKey<ThrioPageState> key,
      this.routeSettings = const ThrioRouteSettings(),
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

  final ThrioRouteSettings routeSettings;

  @override
  StatefulElement createElement() => ContainerElement(this);

  @override
  NavigatorState createState() => ThrioPageState();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) =>
      'Container:${routeSettings.url},${routeSettings.index}';
}

class ContainerElement extends StatefulElement {
  ContainerElement(StatefulWidget widget) : super(widget);
}

class ThrioPageState extends NavigatorState {
  final _routeHistory = <Route>[];

  ThrioPage get pageWidget {
    final widget = super.widget;
    return widget is ThrioPage ? widget : null;
  }

  Future<bool> backPressed() => maybePop();

  @override
  void didUpdateWidget(Navigator oldWidget) {
    super.didUpdateWidget(oldWidget);

    _findThrioNavigatorObserver(oldWidget)?.clear();
  }

  @override
  void dispose() {
    _findThrioNavigatorObserver(widget)?.clear();
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
    ThrioRouter().pop(
      pageWidget.routeSettings.url,
      index: pageWidget.routeSettings.index,
    );

    return false;
  }

  @override
  Future<T> push<T extends Object>(Route<T> route) {
    Route<T> newRoute;

    if (ThrioRouter().navigatorState?.onWillPushRoute != null) {
      newRoute = ThrioRouter()
          .navigatorState
          .onWillPushRoute<T>(pageWidget.routeSettings);
    }

    final future = super.push(newRoute ?? route);

    _routeHistory.add(route);

    if (ThrioRouter().navigatorState?.onDidPushRoute != null) {
      ThrioRouter().navigatorState.onDidPushRoute(pageWidget.routeSettings);
    }

    return future;
  }

  ThrioNavigatorObserver _findThrioNavigatorObserver(Navigator navigator) {
    for (final observer in navigator.observers) {
      if (observer is ThrioNavigatorObserver) {
        return observer;
      }
    }
    return null;
  }
}
