// Copyright (c) 2019/12/03, 10:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/material.dart';

import 'router_exception.dart';
import 'router_route_settings.dart';

/// An route managed by a RouterNavigator.
///
class RouterRoute<T> extends MaterialPageRoute<T> {
  /// Initialize the [Route].
  RouterRoute({
    RouteSettings settings,
    this.routeSettings,
  }) : super(builder: routeSettings.builder, settings: settings);

  /// Router route settings.
  final RouterRouteSettings routeSettings;

  /// Get router route from context.
  ///
  /// If null or not a RouterRoute, a RouterException is thrown.
  ///
  static RouterRoute of(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null && route is RouterRoute) {
      return route;
    }
    throw RouterException('${route.runtimeType} is not a RouterRoute');
  }

  /// Try get router route from context.
  ///
  /// If null or not a RouterRoute, return null.
  ///
  static RouterRoute tryOf(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null && route is RouterRoute) {
      return route;
    }
    return null;
  }
}
