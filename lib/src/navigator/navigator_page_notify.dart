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
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';
import 'thrio_navigator_implement.dart';

class NavigatorPageNotify extends StatefulWidget {
  const NavigatorPageNotify({
    Key? key,
    required this.name,
    required this.onPageNotify,
    this.initialParams,
    required this.child,
  }) : super(key: key);

  final String name;

  final NavigatorParamsCallback onPageNotify;

  final dynamic initialParams;

  final Widget child;

  @override
  _NavigatorPageNotifyState createState() => _NavigatorPageNotifyState();
}

class _NavigatorPageNotifyState extends State<NavigatorPageNotify> {
  // NavigatorPageRoute? _route;

  StreamSubscription? _notifySubscription;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      if (widget.initialParams != null) {
        widget.onPageNotify(widget.initialParams);
      }
    }
  }

  @override
  void didChangeDependencies() {
    _notifySubscription?.cancel();
    final state = context.stateOf<NavigatorWidgetState>();
    final route = state.history.last;
    if (route is NavigatorPageRoute) {
      // _route = route;
      _notifySubscription = ThrioNavigatorImplement.shared()
          .onPageNotify(
            url: route.settings.url!,
            index: route.settings.index,
            name: widget.name,
          )
          .listen(_listen);
    }

    super.didChangeDependencies();
  }

  void _listen(params) {
    if (params != null) {
      if (params is Map) {
        if (params.containsKey('__thrio_Params_HashCode__')) {
          final paramsObjs =
              // ignore: avoid_as
              anchor.removeParam(params['__thrio_Params_HashCode__'] as int);
          widget.onPageNotify(paramsObjs);
          return;
        }
        if (params.containsKey('__thrio_TParams__')) {
          // ignore: avoid_as
          final typeString = params['__thrio_TParams__'] as String;
          final paramsObj = ThrioModule.get<JsonDeserializer>(key: typeString)
              ?.call(params.cast<String, dynamic>());
          if (paramsObj != null) {
            widget.onPageNotify(paramsObj);
            return;
          }
        }
      }
      widget.onPageNotify(params);
    } else {
      widget.onPageNotify(null);
    }
  }

  @override
  void dispose() {
    _notifySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
