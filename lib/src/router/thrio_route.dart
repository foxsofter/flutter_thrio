// Copyright (c) 2019/12/03, 10:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/material.dart';

import '../exception/thrio_exception.dart';
import 'thrio_route_settings.dart';

/// An route managed by a ThrioNavigator.
///
class ThrioRoute<T> extends MaterialPageRoute<T> {
  /// Initialize the [Route].
  ThrioRoute({
    RouteSettings settings,
    this.routeSettings,
  }) : super(builder: routeSettings.builder, settings: settings);

  /// Router route settings.
  final ThrioRouteSettings routeSettings;

  /// Get thrio route from context.
  ///
  /// If null or not a RouterRoute, a ThrioException is thrown.
  ///
  static ThrioRoute of(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null && route is ThrioRoute) {
      return route;
    }
    throw ThrioException('${route.runtimeType} is not a ThrioRoute');
  }

  /// Try get thrio route from context.
  ///
  /// If null or not a RouterRoute, return null.
  ///
  static ThrioRoute tryOf(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null && route is ThrioRoute) {
      return route;
    }
    return null;
  }
}
