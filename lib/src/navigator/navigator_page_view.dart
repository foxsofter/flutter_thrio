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
import 'navigator_page.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorPageView extends StatefulWidget {
  const NavigatorPageView({
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

class _NavigatorPageViewState extends State<NavigatorPageView>
    with NavigatorPageObserver {
  late final controller = widget.controller ?? PageController();

  late RouteSettings current = widget.routeSettings[controller.initialPage];

  late int currentIndex = controller.initialPage;

  Future<void>? onPageChangedFuture;

  VoidCallback? _anchorObserverCallback;
  late RouteSettings _anchor;

  @override
  void didAppear(final RouteSettings routeSettings) {
    if (routeSettings.name == _anchor.name) {
      _changedToAppear(current);
    }
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    if (routeSettings.name == _anchor.name) {
      _changedToDisappear(current);
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _anchor = NavigatorPage.routeSettingsOf(context);
      while (_anchor.parent != null) {
        _anchor = _anchor.parent!;
        if (_anchor.isSelected != null) {
          break;
        }
      }
      _anchorObserverCallback =
          anchor.pageLifecycleObservers.registry(_anchor.url, this);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    _anchorObserverCallback?.call();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => PageView(
        key: widget.key,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: controller,
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
          final isSelected =
              widget.routeSettings.indexOf(it) == controller.initialPage;
          var w = ThrioNavigatorImplement.shared().buildWithSettings(
            context: context,
            settings: it,
            isSelected: isSelected,
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
    onPageChangedFuture ??=
        Future.delayed(const Duration(milliseconds: 120), () {
      final routeSettings = widget.routeSettings[currentIndex];
      if (routeSettings.name != current.name) {
        final oldRouteSettings = current;
        current = routeSettings..isSelected = true;
        for (final it in widget.routeSettings) {
          if (it.name != current.name) {
            it.isSelected = false;
          }
        }
        widget.onPageChanged?.call(routeSettings);
        _changedToDisappear(oldRouteSettings);
        _changedToAppear(routeSettings);
      }
      onPageChangedFuture = null;
    });
  }

  void _changedToAppear(final RouteSettings routeSettings) {
    final obs = anchor.pageLifecycleObservers[routeSettings.url];
    for (final ob in obs) {
      if (ob != this) {
        ob.didAppear(routeSettings);
      }
    }
  }

  void _changedToDisappear(final RouteSettings routeSettings) {
    final obs = anchor.pageLifecycleObservers[routeSettings.url];
    for (final ob in obs) {
      if (ob != this) {
        ob.didDisappear(routeSettings);
      }
    }
  }
}
