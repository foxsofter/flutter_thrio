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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extension/thrio_stateful_widget.dart';
import '../module/module_context.dart';
import 'navigator_logger.dart';
import 'navigator_observer_manager.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

/// A widget that manages a set of child widgets with a stack discipline.
///
class NavigatorWidget extends StatefulWidget {
  const NavigatorWidget({
    Key key,
    this.moduleContext,
    NavigatorObserverManager observerManager,
    this.child,
  })  : _observerManager = observerManager,
        super(key: key);

  final Navigator child;

  final ModuleContext moduleContext;

  final NavigatorObserverManager _observerManager;

  @override
  State<StatefulWidget> createState() => NavigatorWidgetState();
}

class NavigatorWidgetState extends State<NavigatorWidget> {
  final _style = const SystemUiOverlayStyle();

  List<NavigatorPageRoute> get history => widget._observerManager.pageRoutes;

  /// 还无法实现animated=false
  Future<bool> push(
    RouteSettings settings, {
    bool animated = true,
    NavigatorParamsCallback poppedResult,
  }) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }

    final pageBuilder =
        ThrioNavigatorImplement.shared().pageBuilders[settings.url];
    if (pageBuilder == null) {
      return Future.value(false);
    }

    final route = NavigatorPageRoute(
      builder: pageBuilder,
      settings: settings,
    );

    ThrioNavigatorImplement.shared().pageObservers.willAppear(
          route.settings,
          NavigatorRouteAction.push,
        );

    verbose(
      'push: url->${route.settings.url} '
      'index->${route.settings.index} '
      'params->${route.settings.params}',
    );

    // 设置一个空值，避免实际页面打开后不生效
    SystemChrome.setSystemUIOverlayStyle(_style);

    navigatorState.push(route);

    return Future.value(true);
  }

  Future<bool> maybePop(RouteSettings settings, {bool animated = true}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    if (history.isEmpty || settings.name != history.last.settings.name) {
      return false;
    }
    if (await history.last.willPop() != RoutePopDisposition.pop) {
      return false;
    }

    return pop(settings, animated: animated);
  }

  Future<bool> pop(RouteSettings settings, {bool animated = true}) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    if (history.isEmpty || settings.name != history.last.settings.name) {
      return Future.value(false);
    }

    verbose('pop: url->${history.last.settings.url} '
        'index->${history.last.settings.index}');

    final route = history.last;
    // The route has been closed.
    if (route.routeAction == NavigatorRouteAction.pop) {
      return Future.value(false);
    }

    ThrioNavigatorImplement.shared().pageObservers.willDisappear(
          route.settings,
          NavigatorRouteAction.pop,
        );

    route.routeAction = NavigatorRouteAction.pop;
    if (animated) {
      navigatorState.pop();
    } else {
      navigatorState.removeRoute(route);
    }
    return Future.value(true);
  }

  Future<bool> popTo(
    RouteSettings settings, {
    bool animated = true,
  }) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null || history.length < 2) {
      return Future.value(false);
    }

    final index = history.indexWhere((it) => it.settings.name == settings.name);
    if (index == -1 || index == history.length - 1) {
      return Future.value(false);
    }

    final route = history[index];

    verbose('popTo: url->${route.settings.url} '
        'index->${route.settings.index}');

    ThrioNavigatorImplement.shared().pageObservers.willAppear(
          route.settings,
          NavigatorRouteAction.popTo,
        );

    route.routeAction = NavigatorRouteAction.popTo;
    if (animated) {
      navigatorState.popUntil((it) => it.settings.name == settings.name);
    } else {
      if (history.last != route) {
        for (var i = history.length - 2; i > index; i--) {
          if (history[i].settings.name == route.settings.name) {
            break;
          }
          navigatorState.removeRoute(history[i]);
        }
        navigatorState.removeRoute(history.last);
      }
    }
    return Future.value(true);
  }

  Future<bool> remove(RouteSettings settings, {bool animated = false}) {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return Future.value(false);
    }
    final route = history.lastWhere((it) => it.settings.name == settings.name,
        orElse: () => null);
    if (route == null) {
      return Future.value(false);
    }

    verbose('remove: url->${route.settings.url} '
        'index->${route.settings.index}');

    route.routeAction = NavigatorRouteAction.remove;

    if (settings.name == history.last.settings.name) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        ThrioNavigatorImplement.shared().pageObservers.willDisappear(
              route.settings,
              NavigatorRouteAction.remove,
            );
      }
      navigatorState.pop();
      return Future.value(true);
    }

    navigatorState.removeRoute(route);

    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      ThrioNavigatorImplement.shared().ready();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
