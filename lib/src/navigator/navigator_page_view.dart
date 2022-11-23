// The MIT License (MIT)
//
// Copyright (c) 2019 foxsofter
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

import '../extension/thrio_build_context.dart';
import '../module/module_anchor.dart';
import 'navigator_page_observer.dart';
import 'navigator_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_widget.dart';
import 'thrio_navigator.dart';

class NavigatorPageView extends StatefulWidget {
  const NavigatorPageView({
    super.key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    this.controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    this.urls = const <String>[],
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

  final void Function(String)? onPageChanged;

  final List<String> urls;

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
  VoidCallback? _pageObserverCallback;

  late final controller = widget.controller ?? PageController();

  bool isAppeared = true;

  late String current = widget.urls[controller.initialPage];

  void onPageChanged(final int idx) {
    final url = widget.urls[idx];
    if (url != current) {
      final oldUrl = current;
      current = url;
      widget.onPageChanged?.call(url);
      if (isAppeared) {
        final oldObs = anchor.pageLifecycleObservers[oldUrl];
        for (final ob in oldObs) {
          if (ob is! _PageObserver) {
            ob.didDisappear(RouteSettings(name: '0 $oldUrl'));
          }
        }
        final obs = anchor.pageLifecycleObservers[url];
        for (final ob in obs) {
          if (ob is! _PageObserver) {
            ob.didAppear(RouteSettings(name: '0 $url'));
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      final obs = anchor.pageLifecycleObservers[current];
      for (final ob in obs) {
        if (ob is! _PageObserver) {
          ob.didAppear(RouteSettings(name: '0 $current'));
        }
      }
    }
  }

  @override
  void dispose() {
    _pageObserverCallback?.call();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_pageObserverCallback != null) {
      _pageObserverCallback?.call();
      _pageObserverCallback = null;
    }

    final state = context.stateOf<NavigatorWidgetState>();
    final route = state.history.last;
    if (route is NavigatorRoute) {
      _pageObserverCallback = anchor.pageLifecycleObservers.registry(
        route.settings.url!,
        _PageObserver(this),
      );
    }

    super.didChangeDependencies();
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
        children: widget.urls.map((final url) {
          final w = ThrioNavigator.build(url: url);
          if (w == null) {
            throw ArgumentError.value(url, 'url', 'invalid url');
          }
          return w;
        }).toList(),
      );
}

class _PageObserver with NavigatorPageObserver {
  const _PageObserver(this.lifecycleState);

  final _NavigatorPageViewState lifecycleState;

  @override
  void didAppear(final RouteSettings routeSettings) {
    lifecycleState.isAppeared = true;
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    lifecycleState.isAppeared = false;
  }
}
