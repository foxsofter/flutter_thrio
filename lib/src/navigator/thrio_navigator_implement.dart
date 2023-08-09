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

  Future<void> init(final ModuleContext moduleContext) async {
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

  TransitionBuilder get builder => (final context, final child) {
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

  final _pushBeginHandlers = RegistrySet();

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

  VoidCallback registerPushBeginHandle(final NavigatorPushBeginHandle handle) =>
      _pushBeginHandlers.registry(handle);

  Future<TPopParams?> push<TParams, TPopParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) async {
    await _onPushBeginHandle(url: url, params: params);

    final completer = Completer<TPopParams?>();

    final handled = await _pushToHandler(
      url,
      params,
      animated,
      completer,
      result,
    );
    if (!handled) {
      Future<void> pushFuture() {
        final resultCompleter = Completer<void>();
        _pushToNative<TParams, TPopParams>(
          url,
          params,
          animated,
          completer,
        ).then((final index) {
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
    required final String url,
    final TParams? params,
  }) async {
    for (final handle in _pushBeginHandlers) {
      await handle(url, params);
    }
  }

  Future<TPopParams?> _onRouteCustomHandle<TParams, TPopParams>({
    required final NavigatorRouteCustomHandler handler,
    required final Uri uri,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
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
    );
  }

  Future<TPopParams?> pushSingle<TParams, TPopParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) async {
    await _onPushBeginHandle(url: url, params: params);

    final completer = Completer<TPopParams?>();

    final handled = await _pushToHandler(url, params, animated, completer,
        (final index) async {
      result?.call(index);
      if (index > 0) {
        await removeAll(url: url, excludeIndex: index);
      }
    });
    if (!handled) {
      Future<void> pushFuture() {
        final resultCompleter = Completer<TPopParams>();
        _pushToNative<TParams, TPopParams>(url, params, animated, completer)
            .then<void>((final index) async {
          resultCompleter.complete();
          result?.call(index);
          if (index > 0) {
            await removeAll(url: url, excludeIndex: index);
          }
        });
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<TPopParams?> pushReplace<TParams, TPopParams>({
    required final String url,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) async {
    await _onPushBeginHandle(url: url, params: params);

    final completer = Completer<TPopParams>();

    final lastSetting = await lastRoute();
    if (lastSetting == null) {
      throw ThrioException('no route to replace');
    }
    final handled = await _pushToHandler(url, params, animated, completer,
        (final index) async {
      if (index > 0) {
        await remove(url: lastSetting.url, index: lastSetting.index);
      }
      result?.call(index);
    });
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final lastSetting = await lastRoute();
        if (lastSetting == null) {
          throw ThrioException('no route to replace');
        }
        unawaited(
            _pushToNative<TParams, TPopParams>(url, params, animated, completer)
                .then((final index) async {
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
    required final String url,
    required final String toUrl,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) async {
    await _onPushBeginHandle(url: url, params: params);

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route = routes.lastWhereOrNull((final it) => it.url == toUrl);
    if (route == null) {
      result?.call(0);
    }

    final handled = await _pushToHandler(url, params, animated, completer,
        (final index) async {
      if (index > 0) {
        await removeBlowUntil(predicate: (final url) => url == toUrl);
      }
      result?.call(index);
    });
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes.lastWhereOrNull((final it) => it.url == toUrl);
        if (route == null) {
          result?.call(0);
          resultCompleter.complete();
        }
        unawaited(
            _pushToNative<TParams, TPopParams>(url, params, animated, completer)
                .then((final index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBlowUntil(predicate: (final url) => url == toUrl);
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
    required final String url,
    required final String toUrl,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) async {
    await _onPushBeginHandle(url: url, params: params);

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route = routes.firstWhereOrNull((final it) => it.url == toUrl);
    if (route == null) {
      result?.call(0);
    }
    final handled = await _pushToHandler(url, params, animated, completer,
        (final index) async {
      if (index > 0) {
        await removeBlowUntilFirst(predicate: (final url) => url == toUrl);
      }
      result?.call(index);
    });
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes.firstWhereOrNull((final it) => it.url == toUrl);
        if (route == null) {
          result?.call(0);
          resultCompleter.complete();
        }
        unawaited(
            _pushToNative<TParams, TPopParams>(url, params, animated, completer)
                .then((final index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBlowUntilFirst(predicate: (final url) => url == toUrl);
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
    required final String url,
    required final bool Function(String url) predicate,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) async {
    await _onPushBeginHandle(url: url, params: params);

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route = routes
        .lastWhereOrNull((final it) => it.url.isNotEmpty && predicate(it.url));
    if (route == null) {
      result?.call(0);
    }

    final handled = await _pushToHandler(url, params, animated, completer,
        (final index) async {
      if (index > 0) {
        await removeBlowUntil(predicate: predicate);
      }
      result?.call(index);
    });
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes.lastWhereOrNull(
            (final it) => it.url.isNotEmpty && predicate(it.url));
        if (route == null) {
          resultCompleter.complete();
          result?.call(0);
        }
        unawaited(
            _pushToNative<TParams, TPopParams>(url, params, animated, completer)
                .then((final index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBlowUntil(predicate: predicate);
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
    required final String url,
    required final bool Function(String url) predicate,
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) async {
    await _onPushBeginHandle(url: url, params: params);

    final completer = Completer<TPopParams>();

    final routes = await allRoutes();
    final route = routes
        .firstWhereOrNull((final it) => it.url.isNotEmpty && predicate(it.url));
    if (route == null) {
      result?.call(0);
    }

    final handled = await _pushToHandler(url, params, animated, completer,
        (final index) async {
      if (index > 0) {
        await removeBlowUntilFirst(predicate: predicate);
      }
      result?.call(index);
    });
    if (!handled) {
      Future<void> pushFuture() async {
        final resultCompleter = Completer();
        final routes = await allRoutes();
        final route = routes.firstWhereOrNull(
            (final it) => it.url.isNotEmpty && predicate(it.url));
        if (route == null) {
          resultCompleter.complete();
          result?.call(0);
        }
        unawaited(
            _pushToNative<TParams, TPopParams>(url, params, animated, completer)
                .then((final index) async {
          resultCompleter.complete();
          if (index > 0) {
            await removeBlowUntilFirst(predicate: predicate);
          }
          result?.call(index);
        }));
        return resultCompleter.future;
      }

      unawaited(_taskQueue.add(pushFuture));
    }

    return completer.future;
  }

  Future<bool> _pushToHandler<TParams, TPopParams>(
    final String url,
    final TParams? params,
    final bool animated,
    final Completer<TPopParams?> completer,
    final NavigatorIntCallback? result,
  ) async {
    var handled = false;
    final uri = Uri.parse(url);
    var handler =
        anchor.routeCustomHandlers.lastWhereOrNull((final it) => it.match(uri));
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
          result: (final idx) {
            index = idx;
            result?.call(index);
          },
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

  Future<int> _pushToNative<TParams, TPopParams>(
    final String url,
    final TParams? params,
    final bool animated,
    final Completer<TPopParams?> completer,
  ) {
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
    return _sendChannel
        .push(url: noQueryUrl, params: ps, animated: animated)
        .then((final index) {
      if (index > 0) {
        final routeName = '$index $url';
        final routeHistory =
            ThrioNavigatorImplement.shared().navigatorState?.history;
        final route = routeHistory
            ?.lastWhereOrNull((final it) => it.settings.name == routeName);
        if (route != null && route is NavigatorRoute) {
          route.poppedResult =
              (final params) => poppedResult<TPopParams>(completer, params);
        } else {
          // 不在当前页面栈上，则通过name来缓存
          poppedResults[routeName] =
              (final params) => poppedResult<TPopParams>(completer, params);
        }
      }
      return index;
    });
  }

  void poppedResult<TPopParams>(
    final Completer<TPopParams?> completer,
    final dynamic params,
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
    required final String name,
    final TParams? params,
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
    required final bool Function(String url) predicate,
    required final String name,
    final TParams? params,
  }) async {
    final routes = await allRoutes();
    final route = routes
        .firstWhereOrNull((final it) => it.url.isNotEmpty && predicate(it.url));
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
    required final bool Function(String url) predicate,
    required final String name,
    final TParams? params,
  }) async {
    final routes = await allRoutes();
    final all =
        routes.where((final it) => it.url.isNotEmpty && predicate(it.url));
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
    required final bool Function(String url) predicate,
    required final String name,
    final TParams? params,
  }) async {
    final routes = await allRoutes();
    final route = routes
        .lastWhereOrNull((final it) => it.url.isNotEmpty && predicate(it.url));
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
    required final String url,
    required final String name,
    final TParams? params,
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
    required final String url,
    required final String name,
    final TParams? params,
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
    required final String url,
    required final String action,
    final TParams? params,
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
    final TParams? params,
    final bool animated = true,
  }) =>
      _sendChannel.maybePop<TParams>(params: params, animated: animated);

  Future<bool> pop<TParams>({
    final TParams? params,
    final bool animated = true,
  }) {
    Future<bool> popFuture() =>
        _sendChannel.pop<TParams>(params: params, animated: animated);
    return _taskQueue
        .add<bool>(popFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> popFlutter<TParams>({
    final TParams? params,
    final bool animated = true,
  }) {
    Future<bool> popFuture() =>
        _sendChannel.popFlutter<TParams>(params: params, animated: animated);
    return _taskQueue
        .add<bool>(popFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> popToRoot({
    final bool animated = true,
  }) {
    Future<bool> popToFuture() async {
      final rootRoute = await firstRoute();
      if (rootRoute == null) {
        return false;
      }
      return _sendChannel.popTo(
          url: rootRoute.url, index: rootRoute.index, animated: animated);
    }

    return _taskQueue
        .add<bool>(popToFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> popTo({
    required final String url,
    final bool animated = true,
  }) {
    Future<bool> popToFuture() =>
        _sendChannel.popTo(url: url, animated: animated);
    return _taskQueue
        .add<bool>(popToFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> popToFirst({
    required final String url,
    final bool animated = true,
  }) {
    Future<bool> popToFuture() async {
      final route = await firstRoute(url: url);
      if (route == null) {
        return false;
      }
      return _sendChannel.popTo(
          url: route.url, index: route.index, animated: animated);
    }

    return _taskQueue
        .add<bool>(popToFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> popUntil({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) {
    Future<bool> popFuture() async {
      final routes = await allRoutes();
      final route = routes.lastWhereOrNull(
          (final it) => it.url.isNotEmpty && predicate(it.url));
      if (route == null) {
        return false;
      }
      return _sendChannel.popTo(
          url: route.url, index: route.index, animated: animated);
    }

    return _taskQueue
        .add<bool>(popFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> popUntilFirst({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) {
    Future<bool> popFuture() async {
      final routes = await allRoutes();
      final route = routes.firstWhereOrNull(
          (final it) => it.url.isNotEmpty && predicate(it.url));
      if (route == null) {
        return false;
      }
      return _sendChannel.popTo(
          url: route.url, index: route.index, animated: animated);
    }

    return _taskQueue
        .add<bool>(popFuture)
        .then((final value) => value ?? false);
  }

  Future<int> removeAll({
    required final String url,
    final int excludeIndex = 0,
  }) async {
    Future<int> removeFuture() async {
      if (url.isEmpty) {
        return 0;
      }
      var total = 0;
      var isMatch = false;
      final all = (await allRoutes(url: url))
          .where((final it) => it.index != excludeIndex);
      for (final r in all) {
        isMatch = await _sendChannel.remove(url: r.url, index: r.index);
        if (isMatch) {
          total += 1;
        }
      }
      return total;
    }

    return _taskQueue.add<int>(removeFuture).then((final value) => value ?? 0);
  }

  Future<bool> remove({
    required final String url,
    final int index = 0,
    final bool animated = true,
  }) {
    Future<bool> removeFuture() => _sendChannel.remove(
          url: url,
          index: index,
          animated: animated,
        );
    return _taskQueue
        .add<bool>(removeFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> removeFirst({
    required final String url,
    final bool animated = true,
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

    return _taskQueue
        .add<bool>(removeFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> removeBlowUntil({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) {
    Future<bool> removeFuture() async {
      final routes = await allRoutes();
      final route = routes.sublist(0, routes.length - 1).lastWhereOrNull(
          (final it) => it.url.isNotEmpty && predicate(it.url));
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

    return _taskQueue
        .add<bool>(removeFuture)
        .then((final value) => value ?? false);
  }

  Future<bool> removeBlowUntilFirst({
    required final bool Function(String url) predicate,
    final bool animated = true,
  }) {
    Future<bool> removeFuture() async {
      final routes = await allRoutes();
      final route = routes.sublist(0, routes.length - 1).firstWhereOrNull(
          (final it) => it.url.isNotEmpty && predicate(it.url));
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

    return _taskQueue
        .add<bool>(removeFuture)
        .then((final value) => value ?? false);
  }

  Future<int> replace({
    required final String url,
    required final String newUrl,
  }) {
    Future<int> replaceFuture() =>
        _sendChannel.replace(url: url, newUrl: newUrl);
    return _taskQueue.add<int>(replaceFuture).then((final value) => value ?? 0);
  }

  Future<int> replaceFirst({
    required final String url,
    required final String newUrl,
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

    return _taskQueue.add<int>(replaceFuture).then((final value) => value ?? 0);
  }

  Future<bool> canPop() => _sendChannel.canPop();

  Widget? build<TParams>({
    required final String url,
    final int? index,
    final TParams? params,
  }) {
    final settings = NavigatorRouteSettings.settingsWith(
      url: url,
      index: index,
      params: params,
    );
    return buildWithSettings(settings: settings);
  }

  Widget? buildWithSettings<TParams>({required final RouteSettings settings}) {
    final pageBuilder =
        ThrioModule.get<NavigatorPageBuilder>(url: settings.url);
    if (pageBuilder == null) {
      return null;
    }
    settings.isBuilt = true;
    return pageBuilder(settings);
  }

  Future<bool> isInitialRoute(
          {required final String url, final int index = 0}) =>
      _sendChannel.isInitialRoute(url: url, index: index);

  Future<RouteSettings?> firstRoute({final String? url}) async {
    final all = await allRoutes(url: url);
    return all.firstOrNull;
  }

  Future<RouteSettings?> lastRoute({final String? url}) =>
      _sendChannel.lastRoute(url: url);

  Future<List<RouteSettings>> allRoutes({final String? url}) =>
      _sendChannel.allRoutes(url: url);

  NavigatorRoute? lastFlutterRoute({final String? url, final int? index}) {
    final ns = navigatorState;
    if (ns == null) {
      return null;
    }
    var route = ns.history.lastOrNull;
    if (url?.isNotEmpty == true) {
      route = ns.history.lastWhereOrNull((final it) =>
          it is NavigatorRoute &&
          it.settings.url == url &&
          (index == null || it.settings.index == index));
    }
    return route is NavigatorRoute ? route : null;
  }

  List<NavigatorRoute> allFlutterRoutes({final String? url, final int? index}) {
    final ns = navigatorState;
    if (ns == null) {
      return <NavigatorRoute>[];
    }
    if (url?.isNotEmpty == true) {
      return ns.history
          .whereType<NavigatorRoute>()
          .where((final it) =>
              it.settings.url == url &&
              (index == null || it.settings.index == index))
          .toList();
    }
    return ns.history.whereType<NavigatorRoute>().toList();
  }

  bool isDialogAbove({final String? url, final int? index}) {
    final ns = navigatorState;
    if (ns == null) {
      return false;
    }
    if (url?.isNotEmpty == true) {
      final routes = ns.history;
      final idx = routes.lastIndexWhere((final it) =>
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
    required final String url,
    final int index = 0,
    final bool disabled = true,
  }) =>
      _sendChannel.setPopDisabled(url: url, index: index, disabled: disabled);

  Stream<dynamic> onPageNotify({
    required final String name,
    final String? url,
    final int index = 0,
  }) =>
      _receiveChannel.onPageNotify(name: name, url: url, index: index);

  void hotRestart() {
    _channel.invokeMethod<bool>('hotRestart');
  }

  dynamic _deserializeParams(final dynamic params) {
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

  Future<void> syncPagePoppedResults({final NavigatorRoute? route}) async {
    route?.poppedResult?.call(null);
    if (poppedResults.isEmpty) {
      return;
    }
    final routes = await allRoutes();
    if (routes.isEmpty) {
      poppedResults.clear();
    } else {
      poppedResults.removeWhere((final name, final poppedResult) {
        if (!routes.any((final it) => it.name == name)) {
          Future(() => poppedResult.call(null));
          return true;
        }
        return false;
      });
    }
  }
}
