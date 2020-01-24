// Copyright (c) 2019/12/05, 13:40:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:io';

import 'package:flutter/widgets.dart';

import '../app/thrio_app.dart';
import '../channel/thrio_channel.dart';
import '../logger/thrio_logger.dart';
import '../thrio_types.dart';
import 'thrio_route_settings.dart';

class ThrioPageObserver {
  ThrioPageObserver(ThrioChannel channel) : _channel = channel {
    _onScheduleFrame();
    _onPush();
    _onPop();
    _onPopTo();
    _onRemove();
    _onAppeared();
  }

  final ThrioChannel _channel;

  void _onScheduleFrame() {
    _channel.registryMethodCall(
      'scheduleFrame',
      ([_]) {
        WidgetsBinding.instance.scheduleForcedFrame();
        return Future.delayed(
          const Duration(milliseconds: 250),
          WidgetsBinding.instance.scheduleForcedFrame,
        );
      },
    );
  }

  Stream<int> onPageLifecycleStream(
    PageLifecycle lifecycle,
    String url, {
    int index,
  }) =>
      _channel
          .onEventStream(lifecycle.toString())
          .where((arguments) =>
              arguments.containsValue(url) &&
              (index == null || arguments.containsValue(index)))
          .map<int>((arguments) {
        final index = arguments['index'];
        return index is int ? index : null;
      });

  Stream<Map<String, dynamic>> onPageNotifyStream(
    String name,
    String url, {
    int index,
  }) =>
      _channel
          .onEventStream('__onNotify__')
          .where((arguments) =>
              arguments.containsValue(url) &&
              arguments.containsValue(name) &&
              (index == null || arguments.containsValue(index)))
          .map((arguments) {
        final params = arguments['params'];
        return params is Map<String, dynamic> ? params : null;
      });

  void _onPush() => _channel.registryMethodCall(
        '__onPush__',
        ([arguments]) {
          final routeSettings = ThrioRouteSettings.fromArguments(arguments);
          return ThrioApp().navigatorState?.push(routeSettings);
        },
      );

  void _onPop() => _channel.registryMethodCall(
        '__onPop__',
        ([arguments]) => ThrioApp().navigatorState?.pop(),
      );

  void _onPopTo() => _channel.registryMethodCall(
        '__onPopTo__',
        ([arguments]) {
          final routeSettings = ThrioRouteSettings.fromArguments(arguments);
          return ThrioApp().navigatorState?.popTo(routeSettings);
        },
      );

  void _onRemove() => _channel.registryMethodCall(
        '__onRemove__',
        ([arguments]) {
          final routeSettings = ThrioRouteSettings.fromArguments(arguments);
          return ThrioApp().navigatorState?.remove(routeSettings);
        },
      );

  void _onAppeared() => _channel
          .onEventStream(PageLifecycle.appeared.toString())
          .listen((arguments) {
        if (Platform.isAndroid) {
          try {
            final owner = WidgetsBinding.instance.pipelineOwner?.semanticsOwner;
            final root = owner?.rootSemanticsNode;
            root?.detach();
            root?.attach(owner);
          }
          // ignore: avoid_catches_without_on_clauses
          catch (e) {
            ThrioLogger().e(e.toString());
          }
        }
      });
}
