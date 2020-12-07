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

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../extension/thrio_build_context.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';
import 'thrio_navigator_implement.dart';

class NavigatorPageNotify<T> extends StatefulWidget {
  const NavigatorPageNotify({
    Key key,
    @required this.name,
    @required this.onPageNotify,
    this.initialParams,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final String name;

  final NavigatorParamsCallback onPageNotify;

  final T initialParams;

  final Widget child;

  @override
  _NavigatorPageNotifyState<T> createState() => _NavigatorPageNotifyState<T>();
}

class _NavigatorPageNotifyState<T> extends State<NavigatorPageNotify<T>> {
  NavigatorPageRoute _route;

  Stream _notifyStream;
  StreamSubscription _notifySubscription;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      if (widget.initialParams != null) {
        // ignore: avoid_as
        widget.onPageNotify(<T>() => widget.initialParams as T);
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (widget.onPageNotify != null) {
      _notifySubscription?.cancel();
    }
    final state = context.stateOf<NavigatorWidgetState>();
    final route = state.history.last;
    if (route != null && route is NavigatorPageRoute) {
      _route = route;
      _notifyStream = ThrioNavigatorImplement.shared().onPageNotify(
        url: _route.settings.url,
        index: _route.settings.index,
        name: widget.name,
      );
      _notifySubscription = _notifyStream.listen(_listen);
    }

    super.didChangeDependencies();
  }

  void _listen(params) {
    if (params != null) {
      if (params is Map) {
        final typeString =
            params['__thrio_TParams__'] as String; // ignore: avoid_as
        if (typeString != null) {
          final jsonDeserializers =
              ThrioNavigatorImplement.shared().jsonDeserializers;
          final type = jsonDeserializers.keys.lastWhere((it) =>
              it.toString() == typeString ||
              typeString.endsWith(it.toString()));
          final paramsInstance = ThrioNavigatorImplement.shared()
              .jsonDeserializers[type]
              ?.call(params.cast<String, dynamic>());
          if (paramsInstance != null) {
            // ignore: avoid_as
            widget.onPageNotify(<type>() => paramsInstance as type);
            return;
          }
        }
      }
      // ignore: unused_local_variable
      final type = params.runtimeType;
      // ignore: avoid_as
      widget.onPageNotify(<type>() => params as type);
    } else {
      widget.onPageNotify(null);
    }
  }

  // @override
  // void didUpdateWidget(NavigatorPageNotify oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   final state = context.stateOf<NavigatorWidgetState>();
  //   final route = state.history.last;
  //   if (widget.onPageNotify != oldWidget.onPageNotify && _route != null) {
  //     if (oldWidget.onPageNotify != null) {
  //       _notifySubscription?.cancel();
  //     }
  //     if (widget.onPageNotify != null) {
  //       _route = route;
  //       _notifyStream = ThrioNavigatorImplement.onPageNotify(
  //         url: _route.settings.url,
  //         index: _route.settings.index,
  //         name: widget.name,
  //       );
  //       _notifySubscription = _notifyStream.listen(widget.onPageNotify);
  //     }
  //   }
  // }

  @override
  void dispose() {
    if (widget.onPageNotify != null) {
      _notifySubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
