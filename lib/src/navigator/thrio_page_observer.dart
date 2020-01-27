// Copyright (c) 2019/12/05, 13:40:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/widgets.dart';

import '../app/thrio_app.dart';
import '../channel/thrio_channel.dart';
import 'thrio_route_settings.dart';

class ThrioPageObserver {
  ThrioPageObserver(ThrioChannel channel) : _channel = channel {
    _onScheduleFrame();
    _onPush();
    _onPop();
    _onPopTo();
    _onRemove();
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

  void _onPush() => _channel.registryMethodCall('__onPush__', ([arguments]) {
        final routeSettings = ThrioRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioApp().navigatorState?.push(
              routeSettings,
              animated: animated,
            );
      });

  void _onPop() => _channel.registryMethodCall('__onPop__', ([arguments]) {
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioApp().navigatorState?.pop(animated: animated);
      });

  void _onPopTo() => _channel.registryMethodCall('__onPopTo__', ([arguments]) {
        final routeSettings = ThrioRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioApp().navigatorState?.popTo(
              routeSettings,
              animated: animated,
            );
      });

  void _onRemove() =>
      _channel.registryMethodCall('__onRemove__', ([arguments]) {
        final routeSettings = ThrioRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioApp().navigatorState?.remove(
              routeSettings,
              animated: animated,
            );
      });
}
