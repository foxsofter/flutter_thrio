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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extension/thrio_iterable.dart';
import '../extension/thrio_stateful_widget.dart';
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
import 'navigator_logger.dart';
import 'navigator_observer_manager.dart';
import 'navigator_page_route.dart';
import 'navigator_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

/// A widget that manages a set of child widgets with a stack discipline.
///
class NavigatorWidget extends StatefulWidget {
  const NavigatorWidget({
    super.key,
    required this.moduleContext,
    required final NavigatorObserverManager observerManager,
    required this.child,
  }) : _observerManager = observerManager;

  final Navigator child;

  final ModuleContext moduleContext;

  final NavigatorObserverManager _observerManager;

  @override
  State<StatefulWidget> createState() => NavigatorWidgetState();
}

class NavigatorWidgetState extends State<NavigatorWidget> {
  final _style = const SystemUiOverlayStyle();

  List<Route<dynamic>> get history => widget._observerManager.pageRoutes;

  /// 还无法实现animated=false
  Future<bool> push(final RouteSettings settings, {final bool animated = true}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }

    final pageBuilder = ThrioModule.get<NavigatorPageBuilder>(url: settings.url);
    if (pageBuilder == null) {
      return false;
    }

    // 加载模块
    await anchor.loading(settings.url!);

    NavigatorRoute route;
    final routeBuilder = ThrioModule.get<NavigatorRouteBuilder>(url: settings.url);
    if (routeBuilder == null) {
      route = NavigatorPageRoute(pageBuilder: pageBuilder, settings: settings);
    } else {
      route = routeBuilder(pageBuilder, settings);
    }

    ThrioNavigatorImplement.shared()
        .pageChannel
        .willAppear(route.settings, NavigatorRouteAction.push);

    verbose(
      'push: url->${route.settings.url} '
      'index->${route.settings.index} '
      'params->${route.settings.params}',
    );

    // 设置一个空值，避免页面打开后不生效
    SystemChrome.setSystemUIOverlayStyle(_style);

    // ignore: unawaited_futures
    navigatorState.push(route);

    return true;
  }

  Future<bool> canPop(final RouteSettings settings, {final bool inRoot = false}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    if (await history.last.willPop() != RoutePopDisposition.pop) {
      return false;
    }
    // 在原生端处于容器的根部，且当前 Flutter 页面栈上不超过 3，则不能再 pop
    if (inRoot && history.whereType<NavigatorRoute>().length < 3) {
      return false;
    }
    return true;
  }

  Future<bool> maybePop(
    final RouteSettings settings, {
    final bool animated = true,
    final bool inRoot = false,
  }) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    if (settings.name != history.last.settings.name) {
      final poppedResults = ThrioNavigatorImplement.shared().poppedResults;
      if (poppedResults.containsKey(settings.name)) {
        // 不匹配的时候表示这里是非当前引擎触发的，调用 poppedResult 回调
        final poppedResult = poppedResults.remove(settings.name);
        _poppedResultCallback(poppedResult, settings.url!, settings.params);

        return false;
      }
    }
    if (await history.last.willPop() != RoutePopDisposition.pop) {
      return false;
    }
    return pop(settings, animated: animated, inRoot: inRoot);
  }

  Future<bool> pop(
    final RouteSettings settings, {
    final bool animated = true,
    final bool inRoot = false,
  }) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null || history.isEmpty) {
      return false;
    }

    // 关闭非体系内的顶部 route，同时 return false，避免原生端清栈
    if (history.last is! NavigatorRoute) {
      unawaited(navigatorState.maybePop(settings.params).then((final _) => history.removeLast()));
      return false;
    }

    // 不管成功与否都 return false，避免原生端清栈
    // 理论上不可能出现这种情况
    if (settings.name != history.last.settings.name) {
      return false;
    }

    // 在原生端处于容器的根部，且当前 Flutter 页面栈上不超过 3，则不能再 pop
    if (inRoot && history.whereType<NavigatorRoute>().length < 3) {
      return false;
    }

    verbose(
      'pop: url->${history.last.settings.url} '
      'index->${history.last.settings.index}',
    );

    // ignore: avoid_as
    final route = history.last as NavigatorRoute;
    // The route has been closed.
    if (route.routeAction == NavigatorRouteAction.pop) {
      return false;
    }

    ThrioNavigatorImplement.shared()
        .pageChannel
        .willDisappear(route.settings, NavigatorRouteAction.pop);

    route.routeAction = NavigatorRouteAction.pop;
    if (animated) {
      navigatorState.pop();
    } else {
      navigatorState.removeRoute(route);
    }

    return Future.value(true).then((final value) {
      _poppedResultCallback(route.poppedResult, route.settings.url, settings.params);
      return value;
    });
  }

  Future<bool> popTo(final RouteSettings settings, {final bool animated = true}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null || history.length < 2) {
      return false;
    }

    final index = history.indexWhere((final it) => it.settings.name == settings.name);
    if (index == -1) {
      return false;
    }
    // 已经是最顶部的页面了，直接返回 true
    if (index == history.length - 1) {
      return true;
    }

    final route = history[index];

    verbose(
      'popTo: url->${route.settings.url} '
      'index->${route.settings.index}',
    );

    ThrioNavigatorImplement.shared().pageChannel.willAppear(
          route.settings,
          NavigatorRouteAction.popTo,
        );

    // ignore: avoid_as
    (route as NavigatorRoute).routeAction = NavigatorRouteAction.popTo;
    if (animated) {
      navigatorState.popUntil((final it) => it.settings.name == settings.name);
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
    return true;
  }

  Future<bool> remove(final RouteSettings settings, {final bool animated = false}) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    final route = history.firstWhereOrNull((final it) => it.settings.name == settings.name);
    if (route == null) {
      return false;
    }

    verbose(
      'remove: url->${route.settings.url} '
      'index->${route.settings.index}',
    );

    // ignore: avoid_as
    (route as NavigatorRoute).routeAction = NavigatorRouteAction.remove;

    if (settings.name == history.last.settings.name) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        ThrioNavigatorImplement.shared()
            .pageChannel
            .willDisappear(route.settings, NavigatorRouteAction.remove);
      }
      navigatorState.pop();
      return true;
    }

    navigatorState.removeRoute(route);
    return true;
  }

  Future<bool> replace(final RouteSettings settings, final RouteSettings newSettings) async {
    final navigatorState = widget.child.tryStateOf<NavigatorState>();
    if (navigatorState == null) {
      return false;
    }
    final route = history.lastWhereOrNull((final it) => it.settings.name == settings.name);
    if (route == null) {
      return false;
    }
    final pageBuilder = ThrioModule.get<NavigatorPageBuilder>(url: newSettings.url);
    if (pageBuilder == null) {
      return false;
    }

    // 加载模块
    await anchor.loading(newSettings.url!);

    NavigatorRoute newRoute;
    final routeBuilder = ThrioModule.get<NavigatorRouteBuilder>(url: settings.url);
    if (routeBuilder == null) {
      newRoute = NavigatorPageRoute(pageBuilder: pageBuilder, settings: settings);
    } else {
      newRoute = routeBuilder(pageBuilder, settings);
    }

    verbose(
      'replace: url->${route.settings.url} index->${route.settings.index}\n'
      'nweUrl->${newSettings.url} newIndex->${newSettings.index}',
    );

    // ignore: avoid_as
    (route as NavigatorRoute).routeAction = NavigatorRouteAction.replace;

    if (settings.name == history.last.settings.name) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        ThrioNavigatorImplement.shared()
            .pageChannel
            .willDisappear(route.settings, NavigatorRouteAction.replace);
        ThrioNavigatorImplement.shared()
            .pageChannel
            .willAppear(newRoute.settings, NavigatorRouteAction.replace);
      }
      navigatorState.replace(oldRoute: route, newRoute: newRoute);
    } else {
      final anchorRoute = history[history.indexOf(route) + 1];
      navigatorState.replaceRouteBelow(anchorRoute: anchorRoute, newRoute: newRoute);
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      ThrioNavigatorImplement.shared().ready();
    }
  }

  @override
  Widget build(final BuildContext context) => widget.child;

  void _poppedResultCallback(
    final NavigatorParamsCallback? poppedResultCallback,
    final String? url,
    final dynamic params,
  ) {
    if (poppedResultCallback == null) {
      return;
    }
    if (url?.isEmpty ?? true && params == null) {
      poppedResultCallback(null);
    } else {
      if (params is Map) {
        if (params.containsKey('__thrio_Params_HashCode__')) {
          // ignore: avoid_as
          final paramsObjs =
              anchor.removeParam<dynamic>(params['__thrio_Params_HashCode__'] as int);
          poppedResultCallback(paramsObjs);
          return;
        }
        if (params.containsKey('__thrio_TParams__')) {
          // ignore: avoid_as
          final typeString = params['__thrio_TParams__'] as String;
          final paramsObjs = ThrioModule.get<JsonDeserializer<dynamic>>(url: url, key: typeString)
              ?.call(params.cast<String, dynamic>());
          poppedResultCallback(paramsObjs);
          return;
        }
      }
      poppedResultCallback(params);
    }
  }
}
