// Copyright (c) 2019/12/03, 10:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/material.dart';

/// Data that might be useful in constructing a RouterRoute.
@immutable
class RouterRouteSettings {
  /// Creates data used to construct routes.
  const RouterRouteSettings({
    this.url = '/',
    this.index = 0,
    this.params,
    this.builder,
  });

  /// Creates a copy of this route settings object with the given fields
  /// replaced with the new values.
  RouterRouteSettings copyWith({
    String url,
    int index,
    Map<String, dynamic> params,
    WidgetBuilder builder,
  }) =>
      RouterRouteSettings(
        url: url ?? this.url,
        index: index ?? this.index,
        params: params ?? this.params,
        builder: builder ?? this.builder,
      );

  /// The url of the route (e.g., "/settings").
  final String url;

  /// The index of the route being pushed onto this RouterNavigator.
  final int index;

  /// The params passed to this route.
  final Map<String, dynamic> params;

  /// The builder of the route being pushed onto this RouterNavigator.
  final WidgetBuilder builder;

  @override
  int get hashCode => url.hashCode ^ index.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is RouterRouteSettings &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          index == other.index);

  @override
  String toString() => '$runtimeType("$url", $index, $params)';
}
