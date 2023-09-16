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

import 'package:flutter/material.dart';

import '../module/thrio_module.dart';
import 'navigator_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';

/// A route managed by the `ThrioNavigatorImplement`.
///
class NavigatorDialogRoute extends PageRouteBuilder<bool> with NavigatorRoute {
  NavigatorDialogRoute({
    required NavigatorPageBuilder pageBuilder,
    required RouteSettings settings,
    super.transitionDuration,
    super.reverseTransitionDuration,
    super.opaque,
    super.barrierDismissible = false,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState,
    super.fullscreenDialog,
  }) : super(
          pageBuilder: (_, __, ___) => pageBuilder(settings),
          settings: settings,
        );

  @override
  void addScopedWillPopCallback(WillPopCallback callback) {
    setPopDisabled(disabled: true);
    super.addScopedWillPopCallback(callback);
  }

  @override
  void removeScopedWillPopCallback(WillPopCallback callback) {
    setPopDisabled();
    super.removeScopedWillPopCallback(callback);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (settings.isNested) {
      final builder =
          ThrioModule.get<RouteTransitionsBuilder>(url: settings.url);
      if (builder != null) {
        return builder(context, animation, secondaryAnimation, child);
      }
      return super
          .buildTransitions(context, animation, secondaryAnimation, child);
    }
    return child;
  }

  @override
  void dispose() {
    clearPopDisabledFutures();
    super.dispose();
  }
}
