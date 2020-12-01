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
import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import '../extension/thrio_object.dart';
import 'navigator_logger.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorRouteReceiveChannel {
  NavigatorRouteReceiveChannel(ThrioChannel channel) : _channel = channel {
    _onPush();
    _onPop();
    _onPopTo();
    _onRemove();
  }

  final ThrioChannel _channel;

  void _onPush() => _channel.registryMethodCall('push', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        verbose(
          'push: url->${routeSettings.url} '
          'index->${routeSettings.index}',
        );
        routeSettings.params = _deparseParams(routeSettings.params);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.shared()
            .navigatorState
            ?.push(routeSettings, animated: animated)
            ?.then((it) {
          _clearPagePoppedResults();
          return it;
        });
      });

  void _onPop() => _channel.registryMethodCall('pop', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.shared()
            .navigatorState
            ?.maybePop(routeSettings, animated: animated)
            ?.then((it) {
          if (it) {
            final poppedResult = ThrioNavigatorImplement.shared()
                .pagePoppedResults
                .remove(routeSettings.name);
            final params = routeSettings.params;
            if (poppedResult != null) {
              if (params == null) {
                poppedResult(null);
              } else {
                final type = ThrioNavigatorImplement.shared()
                    .pagePoppedResultTypes
                    .remove(routeSettings.name);
                if (type != null && params is Map) {
                  final paramsData = ThrioNavigatorImplement.shared()
                      .jsonDeparsers[type.toString()]
                      ?.call(params.cast<String, dynamic>());
                  if (paramsData != null) {
                    // ignore: avoid_as
                    poppedResult(<type>() => paramsData as type);
                    return it;
                  }
                }
                // ignore: unused_local_variable
                final paramsType = params.runtimeType;
                // ignore: avoid_as
                poppedResult(<paramsType>() => params as paramsType);
              }
            }
            _clearPagePoppedResults(name: routeSettings.name);
          }
          return it;
        });
      });

  void _onPopTo() => _channel.registryMethodCall('popTo', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.shared()
            .navigatorState
            ?.popTo(routeSettings, animated: animated)
            ?.then((it) {
          _clearPagePoppedResults();
          return it;
        });
      });

  void _onRemove() => _channel.registryMethodCall('remove', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.shared()
            .navigatorState
            ?.remove(routeSettings, animated: animated)
            ?.then((it) {
          _clearPagePoppedResults();
          return it;
        });
      });

  void _clearPagePoppedResults({String name}) {
    if (ThrioNavigatorImplement.shared().pagePoppedResults.isEmpty) {
      return;
    }
    final routeHistory =
        ThrioNavigatorImplement.shared().navigatorState?.history;
    if (routeHistory?.isNotEmpty ?? false) {
      ThrioNavigatorImplement.shared()
          .pagePoppedResults
          .removeWhere((key, _) => key == name);
      ThrioNavigatorImplement.shared()
          .pagePoppedResultTypes
          .removeWhere((key, _) => key == name);
    } else {
      ThrioNavigatorImplement.shared().pagePoppedResults.clear();
      ThrioNavigatorImplement.shared().pagePoppedResultTypes.clear();
    }
  }

  Stream onPageNotify({
    @required String url,
    @required int index,
    @required String name,
  }) =>
      _channel
          .onEventStream('__onNotify__')
          .where((arguments) =>
              arguments.containsValue(url) &&
              arguments.containsValue(name) &&
              (index == null || arguments.containsValue(index)))
          .map((arguments) => arguments['params']);

  dynamic _deparseParams(dynamic params) {
    if (params != null && params is Map) {
      final type = params['__thrio_TParams__'] as String; // ignore: avoid_as
      if (type != null) {
        final paramsInstance = ThrioNavigatorImplement.shared()
            .jsonDeparsers[type]
            ?.call(params.cast<String, dynamic>());
        if (paramsInstance != null) {
          return paramsInstance;
        }
      }
    }
    return params;
  }
}
