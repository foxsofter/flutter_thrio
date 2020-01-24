// Copyright (c) 2019/12/03, 10:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/material.dart';

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

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      settings.isNested
          ? child
          : super.buildTransitions(
              context,
              animation,
              secondaryAnimation,
              child,
            );
}
