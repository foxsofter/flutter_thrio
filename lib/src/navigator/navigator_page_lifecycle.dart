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

import 'package:flutter/widgets.dart';

import '../extension/thrio_build_context.dart';
import '../extension/thrio_iterable.dart';
import '../module/module_anchor.dart';
import 'navigator_page.dart';
import 'navigator_page_observer.dart';
import 'navigator_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class NavigatorPageLifecycle extends StatefulWidget {
  const NavigatorPageLifecycle({
    super.key,
    this.url,
    this.willAppear,
    this.didAppear,
    this.willDisappear,
    this.didDisappear,
    required this.child,
  });

  final String? url;
  final NavigatorPageObserverCallback? willAppear;
  final NavigatorPageObserverCallback? didAppear;
  final NavigatorPageObserverCallback? willDisappear;
  final NavigatorPageObserverCallback? didDisappear;
  final Widget child;

  @override
  _NavigatorPageLifecycleState createState() => _NavigatorPageLifecycleState();
}

class _NavigatorPageLifecycleState extends State<NavigatorPageLifecycle> {
  RouteSettings? _settings;

  late final String url = widget.url ?? NavigatorPage.urlOf(context);

  VoidCallback? _pageObserverCallback;

  bool get shouldObserver =>
      widget.willAppear != null ||
      widget.didAppear != null ||
      widget.willDisappear != null ||
      widget.didDisappear != null;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      final state = context.tryStateOf<NavigatorWidgetState>();
      final route = state?.history.lastWhereOrNull(
        (final it) => it is NavigatorRoute && it.settings.url == url,
      );
      if (route != null && route is NavigatorRoute) {
        _settings = route.settings;
      } else {
        // 特殊情形，url 不在栈上，但也要触发 didAppear
        _settings = NavigatorRouteSettings.settingsWith(url: url);
      }
      Future(() => widget.didAppear?.call(_settings!));
    }
  }

  @override
  void didChangeDependencies() {
    if (_pageObserverCallback == null && shouldObserver) {
      _pageObserverCallback = anchor.pageLifecycleObservers.registry(
        url,
        _PageLifecyclePageObserver(this),
      );
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageObserverCallback?.call();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => widget.child;
}

class _PageLifecyclePageObserver with NavigatorPageObserver {
  const _PageLifecyclePageObserver(this.delegate);

  final _NavigatorPageLifecycleState delegate;

  @override
  void willAppear(final RouteSettings routeSettings) {
    final callback = delegate.widget.willAppear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void didAppear(final RouteSettings routeSettings) {
    final callback = delegate.widget.didAppear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void willDisappear(final RouteSettings routeSettings) {
    final callback = delegate.widget.willDisappear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    final callback = delegate.widget.didDisappear;
    _lifecycleCallback(callback, routeSettings);
  }

  void _lifecycleCallback(
    final NavigatorPageObserverCallback? callback,
    final RouteSettings routeSettings,
  ) {
    // url 相同，但只通知 name 相等的
    final settings = delegate._settings;
    if (settings != null && settings.name == routeSettings.name) {
      callback?.call(settings);
    }
  }
}
