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

import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'thrio_navigator.dart';

/// A route managed by the `ThrioNavigator`.
///
class NavigatorPageRoute extends MaterialPageRoute<bool> {
  NavigatorPageRoute({
    @required NavigatorPageBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
            builder: (_) => builder(settings),
            settings: settings,
            maintainState: maintainState,
            fullscreenDialog: fullscreenDialog);

  // WillPopCallback _willPopCallback;

  // WillPopCallback get willPopCallback => _willPopCallback;

  // set willPopCallback(WillPopCallback callback) {
  //   if (_willPopCallback != callback) {
  //     ThrioNavigator.navigatorState.history.last
  //         .removeScopedWillPopCallback(_willPopCallback);
  //     _willPopCallback = callback;
  //     if (isCurrent) {
  //       addScopedWillPopCallback(callback);
  //     }
  //   }
  // }

  @override
  void addScopedWillPopCallback(WillPopCallback callback) {
    if (ThrioNavigator.navigatorState.history.length < 2) {
      ThrioNavigator.setPopDisabled(
        url: settings.url,
        index: settings.index,
        disabled: true,
      );
    }
    super.addScopedWillPopCallback(callback);
  }

  @override
  void removeScopedWillPopCallback(WillPopCallback callback) {
    if (ThrioNavigator.navigatorState.history.length < 2) {
      ThrioNavigator.setPopDisabled(
        url: settings.url,
        index: settings.index,
        disabled: false,
      );
    }
    super.removeScopedWillPopCallback(callback);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      settings.isNested
          ? super.buildTransitions(
              context,
              animation,
              secondaryAnimation,
              child,
            )
          : child;

  @override
  void dispose() {
    super.dispose();
  }
}
