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

import '../extension/thrio_list.dart';
import '../module/thrio_module.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

// ignore: must_be_immutable
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

  List<Widget>? _children;

  List<Widget>? get children => _children;

  @override
  State<NavigatorPageView> createState() => _NavigatorPageViewState();
}

class _NavigatorPageViewState extends State<NavigatorPageView> {
  final _nameSettings = <String, RouteSettings>{};

  List<String> _currentNames = <String>[];

  List<RouteSettings> get routeSettings =>
      _currentNames.map((it) => _nameSettings[it]!).toList();

  RouteSettings get current => routeSettings[currentIndex];

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

  void _checkRouteSettings(List<RouteSettings> settings) {
    final names = settings.map((it) => it.name).toList();
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

  void _mapRouteSettings(List<RouteSettings> settings) {
    final newNames = settings.map<String>((it) => it.name!).toList();
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
  void didUpdateWidget(NavigatorPageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.routeSettings.isNotEmpty) {
      _checkRouteSettings(widget.routeSettings);
      _mapRouteSettings(widget.routeSettings);

      // 重算索引
      currentIndex = widget._realController.initialPage;
      var isSetIndex = false;
      if (widget._realController.positions.isNotEmpty) {
        final idx = widget._realController.page?.round();
        if (idx != null) {
          currentIndex = idx;
          isSetIndex = true;
        }
      }
      // 未设定新的 page，尝试恢复旧的 index
      if (!isSetIndex) {
        final isSame = widget.routeSettings.compareTo(
          oldWidget.routeSettings,
          (a, b) => a.name == b.name,
        );
        // 如果 name 都是一样的，保留选中状态
        if (isSame) {
          final idx = oldWidget._realController.page?.round();
          if (idx != null) {
            currentIndex = idx;
          }
        }
      }

      _initSelectedState();
    }
    if (oldWidget.controller == null) {
      oldWidget._realController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pv = PageView(
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
      children: routeSettings.map((it) {
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
    widget._children =
        (pv.childrenDelegate as SliverChildListDelegate).children;
    return pv;
  }

  void onPageChanged(int idx) {
    if (idx == currentIndex) {
      return;
    }
    final sts = routeSettings[idx];
    final oldRouteSettings = current;
    currentIndex = idx;
    widget.onPageChanged?.call(currentIndex, sts);
    _changedToDisappear(oldRouteSettings);
    oldRouteSettings.isSelected = false;
    current.isSelected = true;
    _changedToAppear(current);
  }

  void _changedToAppear(RouteSettings routeSettings) {
    final obs = ThrioModule.gets<NavigatorPageObserver>(url: routeSettings.url);
    for (final ob in obs) {
      if (ob.settings == null || ob.settings?.name == routeSettings.name) {
        ob.didAppear(routeSettings);
      }
    }
  }

  void _changedToDisappear(RouteSettings routeSettings) {
    final obs = ThrioModule.gets<NavigatorPageObserver>(url: routeSettings.url);
    for (final ob in obs) {
      if (ob.settings == null || ob.settings?.name == routeSettings.name) {
        ob.didDisappear(routeSettings);
      }
    }
  }
}
