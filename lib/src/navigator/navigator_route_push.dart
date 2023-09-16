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

import 'navigator_page_lifecycle_mixin.dart';
import 'navigator_route_push_mixin.dart';
import 'navigator_types.dart';

class NavigatorRoutePush extends StatefulWidget {
  const NavigatorRoutePush({
    super.key,
    required this.onPush,
    this.alwaysTakeEffect = false,
    required this.child,
  });

  /// 拦截路由的 handle，return prevention 表示该路由会被拦截
  ///
  final NavigatorRoutePushHandle onPush;

  /// 表示是否总是拦截
  ///
  /// 默认为 false，表示在页面 disappear 后将不会生效
  ///
  final bool alwaysTakeEffect;

  final Widget child;

  @override
  _NavigatorRoutePushState createState() => _NavigatorRoutePushState();
}

class _NavigatorRoutePushState extends State<NavigatorRoutePush>
    with NavigatorPageLifecycleMixin, NavigatorRoutePushMixin {
  @override
  bool get alwaysTakeEffect => widget.alwaysTakeEffect;

  @override
  NavigatorRoutePushHandle get onPush => widget.onPush;

  @override
  Widget build(BuildContext context) => widget.child;
}
