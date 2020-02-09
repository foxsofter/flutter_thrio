// Copyright (c) 2019/12/03, 10:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/material.dart';

import 'thrio_app.dart';
import 'thrio_route_settings.dart';

typedef ThrioPageBuilder = Widget Function(RouteSettings settings);

/// An route managed by a ThrioNavigator.
///
class ThrioPageRoute extends MaterialPageRoute<bool> {
  ThrioPageRoute({
    @required ThrioPageBuilder builder,
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
      ThrioApp()
          .navigatorState
          .history
          .last
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
