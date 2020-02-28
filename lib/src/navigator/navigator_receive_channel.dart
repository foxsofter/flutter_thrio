// Copyright (c) 2019/12/05, 13:40:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';

import '../channel/thrio_channel.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator.dart';

class NavigatorReceiveChannel {
  NavigatorReceiveChannel(ThrioChannel channel) : _channel = channel {
    _onPush();
    _onPop();
    _onPopTo();
    _onRemove();
    _onSetPopDisabled();
  }

  final ThrioChannel _channel;

  Stream<Map<String, dynamic>> onPageNotify({
    @required String name,
    @required String url,
    @required int index,
  }) =>
      _channel
          .onEventStream('__onNotify__')
          .where((arguments) =>
              arguments.containsValue(url) &&
              arguments.containsValue(name) &&
              (index == null || arguments.containsValue(index)))
          .map((arguments) {
        final params = arguments['params'];
        return params is Map<String, dynamic> ? params : {};
      });

  void _onPush() => _channel.registryMethodCall('__onPush__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigator.navigatorState?.push(
          routeSettings,
          animated: animated,
        );
      });

  void _onPop() => _channel.registryMethodCall('__onPop__', ([arguments]) {
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigator.navigatorState?.pop(animated: animated);
      });

  void _onPopTo() => _channel.registryMethodCall('__onPopTo__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigator.navigatorState?.popTo(
          routeSettings,
          animated: animated,
        );
      });

  void _onRemove() =>
      _channel.registryMethodCall('__onRemove__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigator.navigatorState?.remove(
          routeSettings,
          animated: animated,
        );
      });

  void _onSetPopDisabled() =>
      _channel.registryMethodCall('__onSetPopDisabled__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final disabledValue = arguments['disabled'];
        final disabled =
            (disabledValue != null && disabledValue is bool) && disabledValue;
        return ThrioNavigator.navigatorState?.setPopDisabled(
          routeSettings,
          disabled: disabled,
        );
      });
}
