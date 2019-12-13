// Copyright (c) 2019/12/11, 10:42:59 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/widgets.dart';

import 'router_route_settings.dart';

/// Signature for a function that creates a page widget.
///
typedef PageBuilder = Widget Function(
  String url,
  int index,
  Map<String, dynamic> params,
);

/// States that a router container can be in.
///
enum RouterContainerLifecycle {
  inited,
  willAppear,
  appeared,
  willDisappear,
  disappeared,
  destroyed,
  background,
  foreground,
}

/// Signature for a function that handlers a router container lifecycle event.
///
typedef RouterContainerLifecycleHandler = void Function(
  RouterRouteSettings routeSettings,
  RouterContainerLifecycle lifecycle,
);

/// A router container available navigation actions.
///
enum RouterContainerNavigation {
  push,
  activate,
  pop,
  remove,
}

/// Signature for a function that handlers a router container navigation action.
///
typedef RouterContainerNavigationHandler = void Function(
  RouterRouteSettings routeSettings,
  RouterContainerNavigation navigation,
);
