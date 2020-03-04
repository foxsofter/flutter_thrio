// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'package:flutter/widgets.dart';

extension NavigatorRouteSettings on RouteSettings {
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
