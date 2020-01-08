// Copyright (c) 2019/12/03, 10:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/material.dart';

import '../app/thrio_app.dart';

/// Data that might be useful in constructing a RouterRoute.
///
@immutable
class ThrioRouteSettings {
  /// Creates data used to construct routes.
  ///
  const ThrioRouteSettings({
    this.url = '/',
    this.index = 0,
    this.params,
    this.builder,
  });

  /// Converting arguments to route settings.
  ///
  factory ThrioRouteSettings.fromArguments(Map<String, dynamic> arguments) {
    if ((arguments?.isNotEmpty ?? false) &&
        arguments.containsKey('url') &&
        arguments.containsKey('index')) {
      final urlValue = arguments['url'];
      final url = urlValue is String ? urlValue : null;
      final indexValue = arguments['index'];
      final index = indexValue is int ? indexValue : null;
      final paramsValue = arguments['params'];
      final params = paramsValue is Map
          ? paramsValue.cast<String, dynamic>()
          : <String, dynamic>{};
      final builder = ThrioApp().pageBuilder(url) ??
          ThrioApp().pageBuilder(ThrioApp().defaultUrl);
      return ThrioRouteSettings(
        url: url,
        index: index,
        params: params,
        builder: (context) => builder(
          url,
          index: index,
          params: params,
        ),
      );
    }
    return null;
  }

  /// Creates a copy of this route settings object with the given fields
  /// replaced with the new values.
  ///
  ThrioRouteSettings copyWith({
    String url,
    int index,
    Map<String, dynamic> params,
    WidgetBuilder builder,
  }) =>
      ThrioRouteSettings(
        url: url ?? this.url,
        index: index ?? this.index,
        params: params ?? this.params,
        builder: builder ?? this.builder,
      );

  /// The url of the route (e.g., "/settings").
  ///
  final String url;

  /// The index of the route being pushed onto this ThrioNavigator.
  ///
  final int index;

  /// The params passed to this route.
  ///
  final Map<String, dynamic> params;

  /// The builder of the route being pushed onto this ThrioNavigator.
  ///
  final WidgetBuilder builder;

  @override
  int get hashCode => url.hashCode ^ index.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is ThrioRouteSettings &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          index == other.index);

  @override
  String toString() => '$runtimeType("$url", $index, $params)';
}
