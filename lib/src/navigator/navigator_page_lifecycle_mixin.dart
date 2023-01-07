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

import '../module/module_anchor.dart';
import 'navigator_logger.dart';
import 'navigator_page.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';

mixin NavigatorPageLifecycleMixin<T extends StatefulWidget> on State<T> {
  RouteSettings? _pageSettings;
  VoidCallback? _pageObserverCallback;

  late RouteSettings _widgetSettings;
  VoidCallback? _widgetObserverCallback;

  bool _isInPage = false;

  late final _widgetPageObserver = _WidgetLifecyclePageObserver(this);

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _widgetSettings = NavigatorPage.routeSettingsOf(context);
      _isInPage = _widgetSettings.parent != null;
      if (_isInPage) {
        _pageSettings = NavigatorPage.routeSettingsOf(
          context,
          pageModuleContext: true,
        );
        _pageObserverCallback = anchor.pageLifecycleObservers.registry(
          _pageSettings!.url,
          _PageLifecyclePageObserver(this),
        );
      }
      _widgetObserverCallback = anchor.pageLifecycleObservers.registry(
        _widgetSettings.url,
        _widgetPageObserver,
      );
      if (!_isInPage) {
        Future(() => didAppear(_widgetSettings));
      }
    }
  }

  void didAppear(final RouteSettings settings) {
    verbose('NavigatorPageLifecycleMixin didAppear: $settings');
  }

  void didDisappear(final RouteSettings settings) {
    verbose('NavigatorPageLifecycleMixin didDisappear: $settings');
  }

  @override
  void dispose() {
    _pageObserverCallback?.call();
    _widgetObserverCallback?.call();
    super.dispose();
  }
}

class _WidgetLifecyclePageObserver with NavigatorPageObserver {
  const _WidgetLifecyclePageObserver(this.delegate);

  final NavigatorPageLifecycleMixin delegate;

  @override
  void didAppear(final RouteSettings routeSettings) {
    final callback = delegate.didAppear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    final callback = delegate.didDisappear;
    _lifecycleCallback(callback, routeSettings);
  }

  void _lifecycleCallback(
    final NavigatorPageObserverCallback? callback,
    final RouteSettings routeSettings,
  ) {
    final settings = delegate._widgetSettings;
    if (settings.name == routeSettings.name) {
      callback?.call(settings);
    }
  }
}

class _PageLifecyclePageObserver with NavigatorPageObserver {
  const _PageLifecyclePageObserver(this.delegate);

  final NavigatorPageLifecycleMixin delegate;

  @override
  void didAppear(final RouteSettings routeSettings) {
    final callback = delegate._widgetPageObserver.didAppear;
    _lifecycleCallback(callback, routeSettings);
  }

  @override
  void didDisappear(final RouteSettings routeSettings) {
    final callback = delegate._widgetPageObserver.didDisappear;
    _lifecycleCallback(callback, routeSettings);
  }

  void _lifecycleCallback(
    final NavigatorPageObserverCallback? callback,
    final RouteSettings routeSettings,
  ) {
    final settings = delegate._pageSettings;
    if (settings?.name == routeSettings.name &&
        delegate._widgetSettings.isSelected != false) {
      callback?.call(delegate._widgetSettings);
    }
  }
}
