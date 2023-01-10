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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../module/module_anchor.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorPageView extends StatefulWidget {
  NavigatorPageView({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.routeSettings = const <RouteSettings>[],
    this.childBuilder,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehavior,
    this.padEnds = true,
  });

  final Axis scrollDirection;

  final bool reverse;

  final PageController? controller;

  late final PageController _realController = controller ?? PageController();

  final ScrollPhysics? physics;

  final bool pageSnapping;

  final void Function(RouteSettings)? onPageChanged;

  final List<RouteSettings> routeSettings;

  final Widget Function(
    BuildContext context,
    RouteSettings settings,
    Widget child,
  )? childBuilder;

  final DragStartBehavior dragStartBehavior;

  final bool allowImplicitScrolling;

  final String? restorationId;

  final Clip clipBehavior;

  final ScrollBehavior? scrollBehavior;

  final bool padEnds;

  @override
  State<NavigatorPageView> createState() => _NavigatorPageViewState();
}

class _NavigatorPageViewState extends State<NavigatorPageView> {
  late RouteSettings current =
      widget.routeSettings[widget._realController.initialPage];

  late int currentIndex = widget._realController.initialPage;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _init();
    }
  }

  void _init() {
    current.isSelected = true;
    for (final it in widget.routeSettings) {
      if (it.name != current.name) {
        it.isSelected = false;
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      widget._realController.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(final NavigatorPageView oldWidget) {
    currentIndex = widget._realController.initialPage;
    if (widget._realController.positions.isNotEmpty) {
      final idx = widget._realController.page?.round();
      if (idx != null) {
        currentIndex = idx;
      }
    }
    current = widget.routeSettings[currentIndex];
    _init();
    if (oldWidget.controller == null) {
      oldWidget._realController.dispose();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(final BuildContext context) => PageView(
        key: widget.key,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget._realController,
        physics: widget.physics,
        pageSnapping: widget.pageSnapping,
        onPageChanged: onPageChanged,
        dragStartBehavior: widget.dragStartBehavior,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
        scrollBehavior: widget.scrollBehavior,
        padEnds: widget.padEnds,
        children: widget.routeSettings.map((final it) {
          var w = ThrioNavigatorImplement.shared().buildWithSettings(
            context: context,
            settings: it,
          );
          if (w == null) {
            throw ArgumentError.value(
              it,
              'routeSettings',
              'invalid routeSettings',
            );
          }
          if (widget.childBuilder != null) {
            w = widget.childBuilder!(context, it, w);
          }
          return w;
        }).toList(),
      );

  void onPageChanged(final int idx) {
    currentIndex = idx;
    final routeSettings = widget.routeSettings[currentIndex];
    if (routeSettings.name != current.name) {
      final oldRouteSettings = current;
      current = routeSettings;
      widget.onPageChanged?.call(routeSettings);
      _changedToDisappear(oldRouteSettings);
      oldRouteSettings.isSelected = false;
      current.isSelected = true;
      _changedToAppear(current);
    }
  }

  void _changedToAppear(final RouteSettings routeSettings) {
    final obs = anchor.pageLifecycleObservers[routeSettings.url];
    for (final ob in obs) {
      if (ob.settings == null || ob.settings?.name == routeSettings.name) {
        ob.didAppear(routeSettings);
      }
    }
  }

  void _changedToDisappear(final RouteSettings routeSettings) {
    final obs = anchor.pageLifecycleObservers[routeSettings.url];
    for (final ob in obs) {
      if (ob.settings == null || ob.settings?.name == routeSettings.name) {
        ob.didDisappear(routeSettings);
      }
    }
  }
}
