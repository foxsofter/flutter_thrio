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
import 'navigator_logger.dart';
import 'thrio_navigator_implement.dart';

class NavigatorRoutePush extends StatefulWidget {
  const NavigatorRoutePush({
    super.key,
    required this.urls,
    required this.onPush,
    required this.child,
  });

  final List<String> urls;
  final NavigatorRoutePushHandle onPush;
  final Widget child;

  @override
  _NavigatorRoutePushState createState() => _NavigatorRoutePushState();
}

class _NavigatorRoutePushState extends State<NavigatorRoutePush> {
  VoidCallback? _registry;
  RouteSettings? _lastRouteSettings;
  final _handles = <String, NavigatorRoutePushHandle>{};

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _registry?.call();
      _handles.clear();
      for (final url in widget.urls) {
        _handles[url] = widget.onPush;
      }
      _registry = anchor.pushHandlers.registryAll(_handles);
    }
  }

  @override
  void dispose() {
    _registry?.call();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => NavigatorPageLifecycle(
        didAppear: (final _) {
          _lastRouteSettings = null;
          _registry?.call();
          _registry = anchor.pushHandlers.registryAll(_handles);
        },
        didDisappear: (final _) async {
          _lastRouteSettings = await ThrioNavigatorImplement.shared().lastRoute();
          _registry?.call();
          _registry = null;
          // 延迟 100ms，如果是被上层页面覆盖引起的，则顶部路由会变，如果是推到后台则不会变
          Future.delayed(const Duration(milliseconds: 100), () async {
            final routeSettings = await ThrioNavigatorImplement.shared().lastRoute();
            if (routeSettings != null && routeSettings.name == _lastRouteSettings?.name) {
              _registry?.call();
              _registry = anchor.pushHandlers.registryAll(_handles);
            }
          });
        },
        child: widget.child,
      );
}
