// Copyright (c) 2019/12/03, 10:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/material.dart';

import 'navigator_route_settings.dart';
import 'thrio_navigator.dart';

typedef NavigatorPageBuilder = Widget Function(RouteSettings settings);

/// A route managed by the `ThrioNavigator`.
///
class NavigatorPageRoute extends MaterialPageRoute<bool> {
  NavigatorPageRoute({
    @required NavigatorPageBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: (_) => builder(settings),
            settings: settings,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog);

  WillPopCallback _willPopCallback;
  WillPopCallback get willPopCallback => _willPopCallback;
  set willPopCallback(WillPopCallback callback) {
    if (_willPopCallback != callback) {
      ThrioNavigator.navigatorState.history.last
          .removeScopedWillPopCallback(_willPopCallback);
      _willPopCallback = callback;
      if (isCurrent) {
        addScopedWillPopCallback(callback);
      }
    }
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      settings.isNested
          ? super.buildTransitions(
              context,
              animation,
              secondaryAnimation,
              child,
            )
          : child;
}
