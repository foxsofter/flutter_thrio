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

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../flutter_thrio.dart';
import '../module/module_anchor.dart';
import 'navigator_widget.dart';
import 'thrio_navigator_implement.dart';

class NavigatorRoutePush extends StatefulWidget {
  const NavigatorRoutePush({
    super.key,
    required this.url,
    required this.onPush,
    required this.child,
  });

  final String url;
  final NavigatorRoutePushCallback onPush;
  final Widget child;

  @override
  _NavigatorRoutePushState createState() => _NavigatorRoutePushState();
}

class _NavigatorRoutePushState extends State<NavigatorRoutePush> {
  NavigatorPageRoute? _route;

  VoidCallback? _registry;

  @override
  void dispose() {
    _registry?.call();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final state = context.stateOf<NavigatorWidgetState>();
    final route = state.history.last;
    if (route is NavigatorPageRoute) {
      _route = route;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(final BuildContext context) => NavigatorPageLifecycle(
      didAppear: (final _) {
        _registry?.call();
        _registry = anchor.pushHandlers.registry(widget.url, (
          final settings, {
          final animated = true,
        }) async {
          final r = await widget.onPush(settings, animated: animated);
          if (true == r && _route != null) {
            final route = _route!;
            // 只是替换 url，不触发真正的 replace 操作，因为在 onPush 中已经让用户自行处理了
            unawaited(ThrioNavigatorImplement.shared().replace(
              url: route.settings.url!,
              index: route.settings.index,
              newUrl: widget.url,
              replaceOnly: true,
            ));
          }
          return r;
        });
      },
      didDisappear: (final _) {
        _registry?.call();
        _registry = null;
      },
      child: widget.child);
}