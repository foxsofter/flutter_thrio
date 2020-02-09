// Copyright (c) 2019/1/8, 18:38:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/widgets.dart';

extension ThrioRouteSettings on RouteSettings {
  /// Converting arguments to route settings.
  ///
  static RouteSettings fromArguments(Map<String, dynamic> arguments) {
    if ((arguments?.isNotEmpty ?? false) &&
        arguments.containsKey('url') &&
        arguments.containsKey('index')) {
      final urlValue = arguments['url'];
      final url = urlValue is String ? urlValue : null;
      final indexValue = arguments['index'];
      final index = indexValue is int ? indexValue : null;
      final isNestedValue = arguments['isNested'];
      final isInitialRoute =
          (isNestedValue != null && isNestedValue is bool) && !isNestedValue;
      final paramsValue = arguments['params'];
      final params = paramsValue is Map
          ? paramsValue.cast<String, dynamic>()
          : <String, dynamic>{};
      return RouteSettings(
        name: '$url.$index',
        isInitialRoute: isInitialRoute,
        arguments: params,
      );
    }
    return null;
  }

  Map<String, dynamic> toArguments() => <String, dynamic>{
        'url': url,
        'index': index,
        'params': params,
      };

  /// Creates a copy of this route settings object with the given fields
  /// replaced with the new values.
  ///
  RouteSettings copyWith({
    String url,
    int index,
    bool isNested,
    Map<String, dynamic> params,
  }) =>
      RouteSettings(
        name: '$url.$index',
        isInitialRoute: !isNested,
        arguments: params,
      );

  String get url => (name?.isNotEmpty ?? false) && name.contains('.')
      ? name.split('.').first
      : '';

  int get index => int.tryParse(name?.split('.')?.last) ?? 0;

  bool get isNested => !isInitialRoute;

  Map<String, dynamic> get params =>
      (arguments != null && arguments is Map<String, dynamic>)
          ? arguments as Map<String, dynamic> // ignore: avoid_as
          : <String, dynamic>{};
}
