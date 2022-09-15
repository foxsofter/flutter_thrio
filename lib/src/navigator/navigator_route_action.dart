// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter.
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

import '../../flutter_thrio.dart';
import '../module/module_anchor.dart';
import 'navigator_page_route.dart' as route;
import 'navigator_route_handler.dart';

class NavigatorRouteAction extends StatefulWidget {
  const NavigatorRouteAction({
    final Key? key,
    required this.url,
    required this.onAction,
    required this.action,
    required this.child,
  }) : super(key: key);

  final String url;
  final NavigatorRouteHandleCallback onAction;
  final route.NavigatorRouteAction action;
  final Widget child;

  @override
  _NavigatorRouteActionState createState() => _NavigatorRouteActionState();
}

class _NavigatorRouteActionState extends State<NavigatorRouteAction> {
  VoidCallback? _registry;

  @override
  void dispose() {
    _registry?.call();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => NavigatorPageLifecycle(
      didAppear: (final _) {
        _registry?.call();
        _registry = anchor.routeActionHandlers.registry(
          widget.url,
          _RouteActionHandler(this),
        );
      },
      didDisappear: (final _) {
        _registry?.call();
        _registry = null;
      },
      child: widget.child);
}

class _RouteActionHandler with NavigatorRouteHandler {
  const _RouteActionHandler(this.routeActionState);

  final _NavigatorRouteActionState routeActionState;

  @override
  Future<bool?> onPush(final RouteSettings routeSettings, {final bool animated = true}) async {
    if (routeActionState.widget.action == route.NavigatorRouteAction.push &&
        routeSettings.url == routeActionState.widget.url) {
      final callback = routeActionState.widget.onAction;
      return callback(routeSettings);
    }
    return null;
  }

  @override
  Future<bool?> onPop(final RouteSettings routeSettings, {final bool animated = true}) async {
    if (routeActionState.widget.action == route.NavigatorRouteAction.pop &&
        routeSettings.url == routeActionState.widget.url) {
      final callback = routeActionState.widget.onAction;
      return callback(routeSettings);
    }
    return null;
  }
}
