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
  static RouteSettings? fromArguments(Map<String, dynamic>? arguments) {
    if ((arguments != null && arguments.isNotEmpty) &&
        arguments.containsKey('url') &&
        arguments.containsKey('index')) {
      final urlValue = arguments['url'];
      final url = urlValue is String ? urlValue : null;
      final indexValue = arguments['index'];
      final index = indexValue is int ? indexValue : null;
      final isNestedValue = arguments['isNested'];
      final isNested =
          isNestedValue != null && isNestedValue is bool && isNestedValue;
      final params = arguments['params'];
      return RouteSettings(
        name: '$index $url',
        arguments: <String, dynamic>{'isNested': isNested, 'params': params},
      );
    }
    return null;
  }

  Map<String, dynamic> toArguments() => <String, dynamic>{
        'url': url,
        'index': index,
        'params': params,
      };

  String? get url {
    final settingsName = name;
    return settingsName == null ||
            settingsName.isEmpty ||
            !settingsName.contains(' ')
        ? null
        : settingsName.split(' ').last;
  }

  int get index {
    final settingsName = name;
    return settingsName == null ||
            settingsName.isEmpty ||
            !settingsName.contains(' ')
        ? 0
        : int.tryParse(settingsName.split(' ').first) ?? 0;
  }

  bool get isNested {
    if (arguments != null && arguments is Map<String, dynamic>) {
      // ignore: avoid_as
      final isNestedValue = (arguments as Map<String, dynamic>)['isNested'];
      return isNestedValue != null && isNestedValue is bool && isNestedValue;
    }
    return false;
  }

  dynamic get params {
    if (arguments != null && arguments is Map<String, dynamic>) {
      // ignore: avoid_as
      return (arguments as Map<String, dynamic>)['params'];
    }
    return null;
  }

  set params(dynamic value) {
    if (arguments != null && arguments is Map<String, dynamic>) {
      // ignore: avoid_as
      (arguments as Map<String, dynamic>)['params'] = value;
    }
  }
}
