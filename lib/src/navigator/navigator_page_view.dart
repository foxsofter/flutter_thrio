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

import '../module/thrio_module.dart';
import 'navigator_page_observer.dart';
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
    this.keepIndex = false,
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

  final void Function(int, RouteSettings)? onPageChanged;

  final List<RouteSettings> routeSettings;

  final bool keepIndex;

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
  final _nameSettings = <String, RouteSettings>{};

  List<String> _currentNames = <String>[];

  List<RouteSettings> get routeSettings =>
      _currentNames.map((final it) => _nameSettings[it]!).toList();

  late RouteSettings current =
      routeSettings[widget._realController.initialPage];

  late int currentIndex = widget._realController.initialPage;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      if (widget.routeSettings.isEmpty) {
        return;
      }
      _checkRouteSettings(widget.routeSettings);
      _mapRouteSettings(widget.routeSettings);
      _initSelectedState();
    }
  }

  void _checkRouteSettings(final List<RouteSettings> settings) {
    final names = settings.map((final it) => it.name).toList();
    final nameSet = names.toSet();
    if (nameSet.length != names.length) {
      nameSet.forEach(names.remove);
      throw ArgumentError.value(
        settings,
        'duplicate RouteSettings',
        names.join(','),
      );
    }
  }

  void _mapRouteSettings(final List<RouteSettings> settings) {
    final newNames = settings.map<String>((final it) => it.name!).toList();
    _currentNames = newNames;

    for (final it in settings) {
      if (!_nameSettings.containsKey(it.name)) {
        final tem = NavigatorRouteSettings.settingsWith(
          url: it.url,
          index: widget.keepIndex ? it.index : null,
          params: it.params,
        );
        _nameSettings[it.name!] = tem;
      } else {
        final old = _nameSettings[it.name!]!;
        _nameSettings[it.name!] = NavigatorRouteSettings.settingsWith(
          url: old.url,
          index: old.index,
          params: it.params,
        );
      }
    }
  }

  void _initSelectedState() {
    current.isSelected = true;
    final sts = routeSettings;
    for (final it in sts) {
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
    super.didUpdateWidget(oldWidget);

    if (widget.routeSettings.isNotEmpty) {
      _checkRouteSettings(widget.routeSettings);
      _mapRouteSettings(widget.routeSettings);

      // 重置索引
      currentIndex = widget._realController.initialPage;
      if (widget._realController.positions.isNotEmpty) {
        final idx = widget._realController.page?.round();
        if (idx != null) {
          currentIndex = idx;
        }
      }
      current = routeSettings[currentIndex];

      _initSelectedState();
    }
    if (oldWidget.controller == null) {
      oldWidget._realController.dispose();
    }
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
        children: routeSettings.map((final it) {
          var w = ThrioNavigatorImplement.shared().buildWithSettings(
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

    final sts = routeSettings[currentIndex];
    if (sts.name != current.name) {
      final oldRouteSettings = current;
      current = sts;
      widget.onPageChanged?.call(currentIndex, sts);
      _changedToDisappear(oldRouteSettings);
      oldRouteSettings.isSelected = false;
      current.isSelected = true;
      _changedToAppear(current);
    }
  }

  void _changedToAppear(final RouteSettings routeSettings) {
    final obs = ThrioModule.gets<NavigatorPageObserver>(url: routeSettings.url);
    for (final ob in obs) {
      if (ob.settings == null || ob.settings?.name == routeSettings.name) {
        ob.didAppear(routeSettings);
      }
    }
  }

  void _changedToDisappear(final RouteSettings routeSettings) {
    final obs = ThrioModule.gets<NavigatorPageObserver>(url: routeSettings.url);
    for (final ob in obs) {
      if (ob.settings == null || ob.settings?.name == routeSettings.name) {
        ob.didDisappear(routeSettings);
      }
    }
  }
}
