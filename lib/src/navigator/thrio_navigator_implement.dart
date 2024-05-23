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
import 'package:flutter/widgets.dart';

import '../async/async_task_queue.dart';
import '../channel/thrio_channel.dart';
import '../exception/thrio_exception.dart';
import '../extension/thrio_iterable.dart';
import '../extension/thrio_uri_string.dart';
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
import '../registry/registry_set.dart';
import 'navigator_dialog_route.dart';
import 'navigator_material_app.dart';
import 'navigator_observer_manager.dart';
import 'navigator_page_observer_channel.dart';
import 'navigator_route.dart';
import 'navigator_route_observer_channel.dart';
import 'navigator_route_receive_channel.dart';
import 'navigator_route_send_channel.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'navigator_widget.dart';

class ThrioNavigatorImplement {
  factory ThrioNavigatorImplement.shared() => _default;

  ThrioNavigatorImplement._();

  static final ThrioNavigatorImplement _default = ThrioNavigatorImplement._();

  Future<void> init(ModuleContext moduleContext) async {
    _moduleContext = moduleContext;
    _channel =
        ThrioChannel(channel: '__thrio_app__${moduleContext.entrypoint}');
    ThrioChannel(channel: '__thrio_module_context__${moduleContext.entrypoint}')
        .registryMethodCall('set', ([final arguments]) async {
      if (arguments == null || arguments.isEmpty) {
        return;
      }
      for (final key in arguments.keys) {
        final value = arguments[key];
        if (value == null) {
          anchor.remove<dynamic>(key);
        } else {
          anchor.set(key, _deserializeParams(value));
        }
      }
    });
    _sendChannel = NavigatorRouteSendChannel(_channel);
    _receiveChannel = NavigatorRouteReceiveChannel(_channel);
    routeChannel = NavigatorRouteObserverChannel(moduleContext.entrypoint);
    pageChannel = NavigatorPageObserverChannel(moduleContext.entrypoint);
  }

  TransitionBuilder get builder => (context, child) {
        Navigator? navigator;
        if (child is Navigator) {
          navigator = child;
        }
        if (navigator == null && child is FocusScope) {
          final c = child.child;
          if (c is Navigator) {
            navigator = c;
          }
        }
        if (navigator != null) {
          if (!navigator.observers.contains(observerManager)) {
            navigator.observers.add(observerManager);
          }
          return NavigatorWidget(
            key: _stateKey,
            moduleContext: _moduleContext,
            observerManager: observerManager,
            child: navigator,
          );
        }
        return const SizedBox(
          width: 200,
          height: 100,
          child: Text('child for builder must be Navigator'),
        );
      };

  late final ModuleContext _moduleContext;

  late final _stateKey = GlobalKey<NavigatorWidgetState>();

  NavigatorWidgetState? get navigatorState => _stateKey.currentState;

  final _pushBeginHandlers = RegistrySet<NavigatorPushHandle>();

  final _pushReturnHandlers = RegistrySet<NavigatorPushHandle>();

  final poppedResults = <String, NavigatorParamsCallback>{};

  List<NavigatorRoute> get currentPopRoutes => observerManager.currentPopRoutes;

  late final ThrioChannel _channel;

  late final NavigatorRouteSendChannel _sendChannel;

  late final NavigatorRouteReceiveChannel _receiveChannel;

  late final NavigatorRouteObserverChannel routeChannel;

  late final NavigatorPageObserverChannel pageChannel;

  late final observerManager = NavigatorObserverManager();

  final _taskQueue = AsyncTaskQueue();

  void ready() {
    // 需要将 WidgetsAppState 中的 `didPopRoute` 去掉，否则后续所有的 `didPopRoute` 都不生效了
    final appState = NavigatorMaterialApp.appKey.currentState;
    if (appState != null) {
      final state = GlobalObjectKey(appState).currentState;
      if (state is WidgetsBindingObserver) {
        WidgetsBinding.instance.removeObserver(state as WidgetsBindingObserver);
      }
    }

    _channel.invokeMethod<bool>('ready');
  }

  VoidCallback registerPushBeginHandle(NavigatorPushHandle handle) =>
      _pushBeginHandlers.registry(handle);

  VoidCallback registerPushReturnHandle(NavigatorPushHandle handle) =>
      _pushReturnHandlers.registry(handle);

  Future<TPopParams?> push<TParams, TPopParams>({
    required String url,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    await _onPushBeginHandle(
      url: url,
      params: params,
      fromURL: fromURL,
      innerURL: innerURL,
    );

    final completer = Completer<TPopParams?>();

    final handled = await _pushToHandler(
      url: url,
      params: params,
      animated: animated,
      completer: completer,
      result: result,
      fromURL: fromURL,
      innerURL: innerURL,
    );
    if (!handled) {
      Future<void> pushFuture() {
        final resultCompleter = Completer();
        _pushToNative<TParams, TPopParams>(
          url: url,
          params: params,
          animated: animated,
          completer: completer,
          fromURL: fromURL,
          innerURL: innerURL,
        ).then((index) {
          resultCompleter.complete();
          result?.call(index);
        });
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<void> _onPushBeginHandle<TParams>({
    required String url,
    TParams? params,
    String? fromURL,
    String? innerURL,
  }) async {
    for (final handle in _pushBeginHandlers) {
      await handle(url, params: params, fromURL: fromURL, innerURL: innerURL);
    }
  }

  Future<void> _onPushReturnHandle<TParams>({
    required String url,
    TParams? params,
    String? fromURL,
    String? innerURL,
  }) async {
    for (final handle in _pushReturnHandlers) {
      await handle(url, params: params, fromURL: fromURL, innerURL: innerURL);
    }
  }

  Future<TPopParams?> _onRouteCustomHandle<TParams, TPopParams>({
    required NavigatorRouteCustomHandler handler,
    required Uri uri,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    final queryParametersAll = handler.queryParamsDecoded
        ? uri.queryParametersAll
        : uri.query.rawQueryParametersAll;
    return handler<TParams, TPopParams>(
      uri.toString(),
      queryParametersAll,
      params: params,
      animated: animated,
      result: result,
      fromURL: fromURL,
      innerURL: innerURL,
    );
  }

  Future<TPopParams?> pushSingle<TParams, TPopParams>({
    required String url,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    await _onPushBeginHandle(
      url: url,
      params: params,
      fromURL: fromURL,
      innerURL: innerURL,
    );

    final completer = Completer<TPopParams?>();

    final handled = await _pushToHandler(
      url: url,
      params: params,
      animated: animated,
      completer: completer,
      result: (index) async {
        if (index > 0) {
          await removeAll(url: url, excludeIndex: index);
        }
        result?.call(index);
      },
      fromURL: fromURL,
      innerURL: innerURL,
    );
    if (!handled) {
      Future<void> pushFuture() {
        final resultCompleter = Completer();
        _pushToNative<TParams, TPopParams>(
          url: url,
          params: params,
          animated: animated,
          completer: completer,
          fromURL: fromURL,
          innerURL: innerURL,
        ).then<void>((index) async {
          if (index > 0) {
            await removeAll(url: url, excludeIndex: index);
          }
          resultCompleter.complete();
          result?.call(index);
        });
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<TPopParams?> pushReplace<TParams, TPopParams>({
    required String url,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    await _onPushBeginHandle(
      url: url,
      params: params,
      fromURL: fromURL,
      innerURL: innerURL,
    );

    final completer = Completer<TPopParams>();

    final lastSetting = await lastRoute();
    if (lastSetting == null) {
      throw ThrioException('no route to replace');
    }
    final handled = await _pushToHandler(
      url: url,
      params: params,
      animated: animated,
      completer: completer,
      result: (index) async {
        if (index > 0) {
          await remove(url: lastSetting.url, index: lastSetting.index);
        }
        result?.call(index);
      },
      fromURL: fromURL,
      innerURL: innerURL,
    );
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final lastSetting = await lastRoute();
        if (lastSetting == null) {
          throw ThrioException('no route to replace');
        }
        unawaited(_pushToNative<TParams, TPopParams>(
          url: url,
          params: params,
          animated: animated,
          completer: completer,
          fromURL: fromURL,
          innerURL: innerURL,
        ).then((index) async {
          resultCompleter.complete();
          if (index > 0) {
            await remove(url: lastSetting.url, index: lastSetting.index);
          }
          result?.call(index);
        }));
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<TPopParams?> pushAndRemoveTo<TParams, TPopParams>({
    required String url,
    required String toUrl,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    await _onPushBeginHandle(
      url: url,
      params: params,
      fromURL: fromURL,
      innerURL: innerURL,
    );

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route = routes.lastWhereOrNull((it) => it.url == toUrl);
    if (route == null) {
      result?.call(0);
    }

    final handled = await _pushToHandler(
      url: url,
      params: params,
      animated: animated,
      completer: completer,
      result: (index) async {
        if (index > 0) {
          await removeBelowUntil(predicate: (url) => url == toUrl);
        }
        result?.call(index);
      },
      fromURL: fromURL,
      innerURL: innerURL,
    );
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes.lastWhereOrNull((it) => it.url == toUrl);
        if (route == null) {
          result?.call(0);
          resultCompleter.complete();
        }
        unawaited(_pushToNative<TParams, TPopParams>(
          url: url,
          params: params,
          animated: animated,
          completer: completer,
          fromURL: fromURL,
          innerURL: innerURL,
        ).then((index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBelowUntil(predicate: (url) => url == toUrl);
          }
          result?.call(index);
        }));
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<TPopParams?> pushAndRemoveToFirst<TParams, TPopParams>({
    required String url,
    required String toUrl,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    await _onPushBeginHandle(
      url: url,
      params: params,
      fromURL: fromURL,
      innerURL: innerURL,
    );

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route = routes.firstWhereOrNull((it) => it.url == toUrl);
    if (route == null) {
      result?.call(0);
    }
    final handled = await _pushToHandler(
      url: url,
      params: params,
      animated: animated,
      completer: completer,
      result: (index) async {
        if (index > 0) {
          await removeBelowUntilFirst(predicate: (url) => url == toUrl);
        }
        result?.call(index);
      },
      fromURL: fromURL,
      innerURL: innerURL,
    );
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes.firstWhereOrNull((it) => it.url == toUrl);
        if (route == null) {
          result?.call(0);
          resultCompleter.complete();
        }
        unawaited(_pushToNative<TParams, TPopParams>(
          url: url,
          params: params,
          animated: animated,
          completer: completer,
          fromURL: fromURL,
          innerURL: innerURL,
        ).then((index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBelowUntilFirst(predicate: (url) => url == toUrl);
          }
          result?.call(index);
        }));
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<TPopParams?> pushAndRemoveUntil<TParams, TPopParams>({
    required String url,
    required bool Function(String url) predicate,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    await _onPushBeginHandle(
      url: url,
      params: params,
      fromURL: fromURL,
      innerURL: innerURL,
    );

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route =
        routes.lastWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
    if (route == null) {
      result?.call(0);
    }

    final handled = await _pushToHandler(
      url: url,
      params: params,
      animated: animated,
      completer: completer,
      result: (index) async {
        if (index > 0) {
          await removeBelowUntil(predicate: predicate);
        }
        result?.call(index);
      },
      fromURL: fromURL,
      innerURL: innerURL,
    );
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes
            .lastWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
        if (route == null) {
          resultCompleter.complete();
          result?.call(0);
        }
        unawaited(_pushToNative<TParams, TPopParams>(
          url: url,
          params: params,
          animated: animated,
          completer: completer,
          fromURL: fromURL,
          innerURL: innerURL,
        ).then((index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBelowUntil(predicate: predicate);
          }
          result?.call(index);
        }));
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<TPopParams?> pushAndRemoveUntilFirst<TParams, TPopParams>({
    required String url,
    required bool Function(String url) predicate,
    TParams? params,
    bool animated = true,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    await _onPushBeginHandle(
      url: url,
      params: params,
      fromURL: fromURL,
      innerURL: innerURL,
    );

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route =
        routes.firstWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
    if (route == null) {
      result?.call(0);
    }

    final handled = await _pushToHandler(
      url: url,
      params: params,
      animated: animated,
      completer: completer,
      result: (index) async {
        if (index > 0) {
          await removeBelowUntilFirst(predicate: predicate);
        }
        result?.call(index);
      },
      fromURL: fromURL,
      innerURL: innerURL,
    );
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes
            .firstWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
        if (route == null) {
          resultCompleter.complete();
          result?.call(0);
        }
        unawaited(_pushToNative<TParams, TPopParams>(
          url: url,
          params: params,
          animated: animated,
          completer: completer,
          fromURL: fromURL,
          innerURL: innerURL,
        ).then((index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBelowUntilFirst(predicate: predicate);
          }
          result?.call(index);
        }));
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<bool> _pushToHandler<TParams, TPopParams>({
    required String url,
    TParams? params,
    required bool animated,
    required Completer<TPopParams?> completer,
    NavigatorIntCallback? result,
    String? fromURL,
    String? innerURL,
  }) async {
    var handled = false;
    final uri = Uri.parse(url);
    var handler =
        anchor.routeCustomHandlers.lastWhereOrNull((it) => it.match(uri));
    if (handler != null) {
      for (var i = anchor.routeCustomHandlers.length - 1; i >= 0; i--) {
        final entry = anchor.routeCustomHandlers.elementAt(i);
        if (!entry.key.match(uri)) {
          continue;
        }
        handler = entry.value;
        var index = 0;
        final pr = await _onRouteCustomHandle<TParams, TPopParams>(
          handler: handler,
          uri: uri,
          params: params,
          animated: animated,
          result: (idx) {
            index = idx;
            result?.call(index);
          },
          fromURL: fromURL,
          innerURL: innerURL,
        );
        if (index != navigatorResultTypeNotHandled) {
          handled = true;
          poppedResult(completer, pr);
          break;
        }
      }
    }
    return handled;
  }

  Future<int> _pushToNative<TParams, TPopParams>({
    required String url,
    TParams? params,
    required bool animated,
    required Completer<TPopParams?> completer,
    String? fromURL,
    String? innerURL,
  }) {
    final qidx = url.indexOf('?');
    final ps = params ?? <String, dynamic>{};
    var noQueryUrl = url;
    if (qidx != -1) {
      if (ps is Map) {
        final query = url.substring(qidx);
        final qps = query.rawQueryParameters;
        ps.addAll(qps);
      }
      noQueryUrl = url.substring(0, qidx);
    }
    unawaited(completer.future.then((value) {
      _onPushReturnHandle(
        url: url,
        params: params,
        fromURL: fromURL,
        innerURL: innerURL,
      );
    }));

    return _sendChannel
        .push(
      url: noQueryUrl,
      params: ps,
      animated: animated,
      fromURL: fromURL,
      innerURL: innerURL,
    )
        .then((index) {
      if (index > 0) {
        final routeName = '$index $noQueryUrl';
        final routeHistory =
            ThrioNavigatorImplement.shared().navigatorState?.history;
        final route = routeHistory
            ?.lastWhereOrNull((it) => it.settings.name == routeName);
        if (route != null && route is NavigatorRoute) {
          route.poppedResult =
              (params) => poppedResult<TPopParams>(completer, params);
        } else {
          // 不在当前页面栈上，则通过name来缓存
          poppedResults[routeName] =
              (params) => poppedResult<TPopParams>(completer, params);
        }
      }
      return index;
    });
  }

  void poppedResult<TPopParams>(
    Completer<TPopParams?> completer,
    dynamic params,
  ) {
    if (completer.isCompleted) {
      return;
    }
    if (params == null) {
      completer.complete(null);
    } else if (params is TPopParams) {
      completer.complete(params);
    } else {
      completer
          .completeError(ArgumentError('invalid params: $params', 'params'));
    }
  }

  Future<bool> notifyAll<TParams>({
    required String name,
    TParams? params,
  }) async {
    final all = await allRoutes();
    if (all.isEmpty) {
      return false;
    }
    for (final route in all) {
      if (route.url.isEmpty) {
        continue;
      }
      await _sendChannel.notify<TParams>(
        name: name,
        url: route.url,
        index: route.index,
        params: params,
      );
    }
    return true;
  }

  Future<bool> notifyFirstWhere<TParams>({
    required bool Function(String url) predicate,
    required String name,
    TParams? params,
  }) async {
    final routes = await allRoutes();
    final route =
        routes.firstWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
    if (route == null) {
      return false;
    }
    await _sendChannel.notify<TParams>(
      name: name,
      url: route.url,
      index: route.index,
      params: params,
    );
    return true;
  }

  Future<bool> notifyWhere<TParams>({
    required bool Function(String url) predicate,
    required String name,
    TParams? params,
  }) async {
    final routes = await allRoutes();
    final all = routes.where((it) => it.url.isNotEmpty && predicate(it.url));
    if (all.isEmpty) {
      return false;
    }
    for (final route in all) {
      await _sendChannel.notify<TParams>(
        name: name,
        url: route.url,
        index: route.index,
        params: params,
      );
    }
    return true;
  }

  Future<bool> notifyLastWhere<TParams>({
    required bool Function(String url) predicate,
    required String name,
    TParams? params,
  }) async {
    final routes = await allRoutes();
    final route =
        routes.lastWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
    if (route == null) {
      return false;
    }
    await _sendChannel.notify<TParams>(
      name: name,
      url: route.url,
      index: route.index,
      params: params,
    );
    return true;
  }

  Future<bool> notifyFirst<TParams>({
    required String url,
    required String name,
    TParams? params,
  }) async {
    final route = await firstRoute(url: url);
    if (route == null || route.url.isEmpty) {
      return false;
    }
    return _sendChannel.notify<TParams>(
      name: name,
      url: route.url,
      index: route.index,
      params: params,
    );
  }

  Future<bool> notifyLast<TParams>({
    required String url,
    required String name,
    TParams? params,
  }) async {
    final route = await lastRoute(url: url);
    if (route == null || route.url.isEmpty) {
      return false;
    }
    return _sendChannel.notify<TParams>(
      name: name,
      url: route.url,
      index: route.index,
      params: params,
    );
  }

  Future<TResult?> act<TParams, TResult>({
    required String url,
    required String action,
    TParams? params,
  }) async {
    final routeAction = anchor.get<NavigatorRouteAction>(url: url, key: action);
    if (routeAction == null) {
      return null;
    }
    final actionUri = Uri.parse(action);
    return routeAction<TParams, TResult>(
      url,
      actionUri.path,
      actionUri.queryParametersAll,
      params: params,
    );
  }

  Future<bool> maybePop<TParams>({
    TParams? params,
    bool animated = true,
  }) =>
      _sendChannel.maybePop<TParams>(
        params: params,
        animated: animated,
      );

  Future<bool> pop<TParams>({
    TParams? params,
    bool animated = true,
  }) {
    Future<bool> popFuture() => _sendChannel.pop<TParams>(
          params: params,
          animated: animated,
        );
    return _taskQueue.add<bool>(popFuture).then((value) => value ?? false);
  }

  Future<bool> popFlutter<TParams>({
    TParams? params,
    bool animated = true,
  }) {
    Future<bool> popFuture() => _sendChannel.popFlutter<TParams>(
          params: params,
          animated: animated,
        );
    return _taskQueue.add<bool>(popFuture).then((value) => value ?? false);
  }

  Future<bool> popToRoot({
    bool animated = true,
  }) {
    Future<bool> popToFuture() async {
      final rootRoute = await firstRoute();
      if (rootRoute == null) {
        return false;
      }
      return _sendChannel.popTo(
        url: rootRoute.url,
        index: rootRoute.index,
        animated: animated,
      );
    }

    return _taskQueue.add<bool>(popToFuture).then((value) => value ?? false);
  }

  Future<bool> popTo({
    required String url,
    int? index,
    bool animated = true,
  }) {
    Future<bool> popToFuture() => _sendChannel.popTo(
          url: url,
          index: index ?? 0,
          animated: animated,
        );
    return _taskQueue.add<bool>(popToFuture).then((value) => value ?? false);
  }

  Future<bool> popToFirst({
    required String url,
    bool animated = true,
  }) {
    Future<bool> popToFuture() async {
      final route = await firstRoute(url: url);
      if (route == null) {
        return false;
      }
      return _sendChannel.popTo(
          url: route.url, index: route.index, animated: animated);
    }

    return _taskQueue.add<bool>(popToFuture).then((value) => value ?? false);
  }

  Future<bool> popUntil({
    required bool Function(String url) predicate,
    bool animated = true,
  }) {
    Future<bool> popFuture() async {
      final routes = await allRoutes();
      final route = routes
          .lastWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
      if (route == null) {
        return false;
      }
      return _sendChannel.popTo(
          url: route.url, index: route.index, animated: animated);
    }

    return _taskQueue.add<bool>(popFuture).then((value) => value ?? false);
  }

  Future<bool> popUntilFirst({
    required bool Function(String url) predicate,
    bool animated = true,
  }) {
    Future<bool> popFuture() async {
      final routes = await allRoutes();
      final route = routes
          .firstWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
      if (route == null) {
        return false;
      }
      return _sendChannel.popTo(
          url: route.url, index: route.index, animated: animated);
    }

    return _taskQueue.add<bool>(popFuture).then((value) => value ?? false);
  }

  Future<int> removeAll({
    required String url,
    int excludeIndex = 0,
  }) async {
    if (url.isEmpty) {
      return 0;
    }
    var total = 0;
    var isMatch = false;
    final all =
        (await allRoutes(url: url)).where((it) => it.index != excludeIndex);
    for (final r in all) {
      isMatch = await _sendChannel.remove(url: r.url, index: r.index);
      if (isMatch) {
        total += 1;
      }
    }
    return total;
  }

  Future<bool> remove({
    required String url,
    int index = 0,
    bool animated = true,
  }) {
    Future<bool> removeFuture() => _sendChannel.remove(
          url: url,
          index: index,
          animated: animated,
        );
    return _taskQueue.add<bool>(removeFuture).then((value) => value ?? false);
  }

  Future<bool> removeFirst({
    required String url,
    bool animated = true,
  }) {
    Future<bool> removeFuture() async {
      final route = await firstRoute(url: url);
      if (route == null) {
        return false;
      }
      return _sendChannel.remove(
        url: route.url,
        index: route.index,
        animated: animated,
      );
    }

    return _taskQueue.add<bool>(removeFuture).then((value) => value ?? false);
  }

  Future<bool> removeBelowUntil({
    required bool Function(String url) predicate,
    bool animated = true,
  }) {
    Future<bool> removeFuture() async {
      final routes = await allRoutes();
      final route = routes
          .sublist(0, routes.length - 1)
          .lastWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
      if (route == null) {
        return false;
      }
      final index = routes.indexOf(route);
      final all = routes.getRange(index + 1, routes.length - 1);
      for (final r in all) {
        await _sendChannel.remove(url: r.url, index: r.index);
      }
      return true;
    }

    return _taskQueue.add<bool>(removeFuture).then((value) => value ?? false);
  }

  Future<bool> removeBelowUntilFirst({
    required bool Function(String url) predicate,
    bool animated = true,
  }) {
    Future<bool> removeFuture() async {
      final routes = await allRoutes();
      final route = routes
          .sublist(0, routes.length - 1)
          .firstWhereOrNull((it) => it.url.isNotEmpty && predicate(it.url));
      if (route == null) {
        return false;
      }
      final index = routes.indexOf(route);
      final all = routes.getRange(index + 1, routes.length - 1);
      for (final r in all) {
        await _sendChannel.remove(url: r.url, index: r.index);
      }
      return true;
    }

    return _taskQueue.add<bool>(removeFuture).then((value) => value ?? false);
  }

  Future<int> replace({
    required String url,
    required String newUrl,
  }) {
    Future<int> replaceFuture() =>
        _sendChannel.replace(url: url, newUrl: newUrl);
    return _taskQueue.add<int>(replaceFuture).then((value) => value ?? 0);
  }

  Future<int> replaceFirst({
    required String url,
    required String newUrl,
  }) {
    Future<int> replaceFuture() async {
      final route = await firstRoute(url: url);
      if (route == null) {
        return 0;
      }
      return _sendChannel.replace(
        url: route.url,
        index: route.index,
        newUrl: newUrl,
      );
    }

    return _taskQueue.add<int>(replaceFuture).then((value) => value ?? 0);
  }

  Future<bool> canPop() => _sendChannel.canPop();

  Widget? build<TParams>({
    required String url,
    int? index,
    TParams? params,
  }) {
    final settings = NavigatorRouteSettings.settingsWith(
      url: url,
      index: index,
      params: params,
    );
    return buildWithSettings(settings: settings);
  }

  Widget? buildWithSettings<TParams>({required RouteSettings settings}) {
    final pageBuilder =
        ThrioModule.get<NavigatorPageBuilder>(url: settings.url);
    if (pageBuilder == null) {
      return null;
    }
    settings.isBuilt = true;
    return pageBuilder(settings);
  }

  Future<bool> isInitialRoute({required String url, int index = 0}) =>
      _sendChannel.isInitialRoute(url: url, index: index);

  Future<RouteSettings?> firstRoute({String? url}) async {
    final all = await allRoutes(url: url);
    return all.firstOrNull;
  }

  Future<RouteSettings?> lastRoute({String? url}) =>
      _sendChannel.lastRoute(url: url);

  Future<List<RouteSettings>> allRoutes({String? url}) =>
      _sendChannel.allRoutes(url: url);

  NavigatorRoute? lastFlutterRoute({String? url, int? index}) {
    final ns = navigatorState;
    if (ns == null) {
      return null;
    }
    var route = ns.history.lastOrNull;
    if (url?.isNotEmpty == true) {
      route = ns.history.lastWhereOrNull((it) =>
          it is NavigatorRoute &&
          it.settings.url == url &&
          (index == null || it.settings.index == index));
    }
    return route is NavigatorRoute ? route : null;
  }

  List<NavigatorRoute> allFlutterRoutes({String? url, int? index}) {
    final ns = navigatorState;
    if (ns == null) {
      return <NavigatorRoute>[];
    }
    if (url?.isNotEmpty == true) {
      return ns.history
          .whereType<NavigatorRoute>()
          .where((it) =>
              it.settings.url == url &&
              (index == null || it.settings.index == index))
          .toList();
    }
    return ns.history.whereType<NavigatorRoute>().toList();
  }

  bool isDialogAbove({String? url, int? index}) {
    final ns = navigatorState;
    if (ns == null) {
      return false;
    }
    if (url?.isNotEmpty == true) {
      final routes = ns.history;
      final idx = routes.lastIndexWhere((it) =>
          it is NavigatorRoute &&
          it.settings.url == url &&
          (index == null || it.settings.index == index));
      if (idx < 0 || routes.length <= idx + 1) {
        return false;
      }
      return routes[idx + 1] is NavigatorDialogRoute;
    }
    return ns.history.last is NavigatorDialogRoute;
  }

  Future<bool> setPopDisabled({
    required String url,
    int index = 0,
    bool disabled = true,
  }) =>
      _sendChannel.setPopDisabled(url: url, index: index, disabled: disabled);

  Stream<dynamic> onPageNotify({
    required String name,
    String? url,
    int index = 0,
  }) =>
      _receiveChannel.onPageNotify(name: name, url: url, index: index);

  void hotRestart() {
    _channel.invokeMethod<bool>('hotRestart');
  }

  dynamic _deserializeParams(dynamic params) {
    if (params == null) {
      return null;
    }

    if (params is Map && params.containsKey('__thrio_TParams__')) {
      // ignore: avoid_as
      final typeString = params['__thrio_TParams__'] as String;
      if (typeString.isNotEmpty) {
        final paramsObj =
            ThrioModule.get<JsonDeserializer<dynamic>>(key: typeString)
                ?.call(params.cast<String, dynamic>());
        if (paramsObj != null) {
          return paramsObj;
        }
      }
    }

    return params;
  }

  Future<void> syncPagePoppedResults({NavigatorRoute? route}) async {
    route?.poppedResult?.call(null);
    if (poppedResults.isEmpty) {
      return;
    }
    final routes = await allRoutes();
    if (routes.isEmpty) {
      poppedResults.clear();
    } else {
      poppedResults.removeWhere((name, poppedResult) {
        if (!routes.any((it) => it.name == name)) {
          Future(() => poppedResult.call(null));
          return true;
        }
        return false;
      });
    }
  }
}
