// Copyright (c) 2019/12/11, 10:42:59 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/widgets.dart';

import 'router/thrio_route_settings.dart';

/// Signature for a function that creates a page widget.
///
typedef PageBuilder = Widget Function(
  String url, {
  int index,
  Map<String, dynamic> params,
});

/// States that a thrio page can be in.
///
enum PageLifecycle {
  inited,
  willAppear,
  appeared,
  willDisappear,
  disappeared,
  destroyed,
  background,
  foreground,
}

/// Signature for a function that handlers a thrio page lifecycle.
///
typedef PageLifecycleHandler = void Function(
  ThrioRouteSettings routeSettings,
  PageLifecycle lifecycle,
);

/// A thrio router available navigation event.
///
enum NavigationEvent {
  push,
  activate,
  pop,
  remove,
}
