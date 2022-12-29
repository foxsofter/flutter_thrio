// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter
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

import 'package:flutter/foundation.dart';

import '../exception/thrio_exception.dart';
import '../navigator/navigator_url_template.dart';
import '../registry/registry_order_map.dart';
import 'module_types.dart';
import 'thrio_module.dart';

mixin ModuleRouteAction on ThrioModule {
  /// A collection of route action.
  ///
  final _routeActionHandlers =
      RegistryOrderMap<NavigatorUrlTemplate, NavigatorRouteAction>();

  NavigatorRouteAction? getRouteAction(final String action) {
    final a = action.replaceAll('?', '='); // ? 通过 Uri 解析会引起截断，先替换成 =
    return _routeActionHandlers
        .lastWhereOrNull((final k) => k.match(Uri.parse(a)));
  }

  /// Register a route action.
  ///
  /// format of `template` is 'login{userName?,password}'
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  @protected
  VoidCallback registerRouteAction(
    final String template,
    final NavigatorRouteAction action,
  ) {
    final key = NavigatorUrlTemplate(template: template);
    if (key.scheme.isNotEmpty) {
      throw ThrioException(
        'action url template should not contains scheme: $template',
      );
    }
    if (_routeActionHandlers.keys.contains(key)) {
      throw ThrioException('duplicate action url template: $template');
    }
    return _routeActionHandlers.registry(key, action);
  }

  /// A function for register a `NavigatorRouteAction` .
  ///
  @protected
  void onRouteActionRegister(final ModuleContext moduleContext) {}
}
