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

import 'package:flutter/material.dart';
import '../module/thrio_module.dart';

import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

enum NavigatorRouteAction { push, pop, popTo, remove, replace }

/// A route managed by the `ThrioNavigatorImplement`.
///
class NavigatorPageRoute extends MaterialPageRoute<bool> {
  NavigatorPageRoute({
    required final NavigatorPageBuilder builder,
    required final RouteSettings settings,
    super.maintainState,
    super.fullscreenDialog,
    final bool opaque = true,
  })  : _opaque = opaque,
        super(builder: (final _) => builder(settings), settings: settings);

  NavigatorRouteAction? routeAction;

  NavigatorParamsCallback? poppedResult;

  final _popDisableds = <String, bool>{};

  final _popDisabledFutures = <String, Future<dynamic>>{};

  final bool _opaque;

  @override
  bool get opaque => _opaque;

  @override
  void addScopedWillPopCallback(final WillPopCallback callback) {
    _setPopDisabled(true);
    super.addScopedWillPopCallback(callback);
  }

  @override
  void removeScopedWillPopCallback(final WillPopCallback callback) {
    _setPopDisabled(false);
    super.removeScopedWillPopCallback(callback);
  }

  void _setPopDisabled(final bool disabled) {
    _popDisableds[settings.name!] = disabled;

    // 延迟300ms执行，避免因为WillPopScope依赖变更导致发送过多的Channel消息
    _popDisabledFutures[settings.name!] ??= Future.delayed(const Duration(milliseconds: 300), () {
      _popDisabledFutures.remove(settings.name); // ignore: unawaited_futures
      final disabled = _popDisableds.remove(settings.name);
      if (disabled != null) {
        ThrioNavigatorImplement.shared().setPopDisabled(
          url: settings.url!,
          index: settings.index,
          disabled: disabled,
        );
      }
    });
  }

  @override
  Widget buildTransitions(
    final BuildContext context,
    final Animation<double> animation,
    final Animation<double> secondaryAnimation,
    final Widget child,
  ) {
    if (settings.isNested) {
      final builder = ThrioModule.get<RouteTransitionsBuilder>(url: settings.url);
      if (builder != null) {
        return builder(context, animation, secondaryAnimation, child);
      }
      return super.buildTransitions(context, animation, secondaryAnimation, child);
    }
    return child;
  }

  @override
  void dispose() {
    _popDisabledFutures.clear();
    super.dispose();
  }
}
