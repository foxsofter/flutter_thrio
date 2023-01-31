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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../module/module_anchor.dart';
import 'navigator_page_lifecycle_mixin.dart';
import 'navigator_types.dart';

class NavigatorRoutePush extends StatefulWidget {
  const NavigatorRoutePush({
    super.key,
    required this.urls,
    required this.onPush,
    required this.child,
    this.alwaysTakeEffect = false,
  });

  final List<String> urls;
  final NavigatorRoutePushHandle onPush;
  final Widget child;

  /// 表示是否总是拦截
  ///
  /// 默认为 false，表示在页面 disappear 后将不会生效
  ///
  final bool alwaysTakeEffect;

  @override
  _NavigatorRoutePushState createState() => _NavigatorRoutePushState();
}

class _NavigatorRoutePushState extends State<NavigatorRoutePush>
    with NavigatorPageLifecycleMixin {
  VoidCallback? _registry;
  final _handles = <String, NavigatorRoutePushHandle>{};

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _init();
    }
  }

  @override
  void didUpdateWidget(covariant final NavigatorRoutePush oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.urls, oldWidget.urls)) {
      _init();
    }
  }

  void _init() {
    for (final url in widget.urls) {
      _handles[url] = widget.onPush;
    }
    _registry?.call();
    _registry = anchor.pushHandlers.registryAll(_handles);
  }

  @override
  void dispose() {
    _registry?.call();
    super.dispose();
  }

  @override
  void didAppear(final RouteSettings settings) {
    if (widget.alwaysTakeEffect) {
      return;
    }
    _registry?.call();
    _registry = anchor.pushHandlers.registryAll(_handles);
  }

  @override
  void didDisappear(final RouteSettings settings) {
    if (widget.alwaysTakeEffect) {
      return;
    }
    _registry?.call();
    _registry = null;
  }

  @override
  Widget build(final BuildContext context) => widget.child;
}
