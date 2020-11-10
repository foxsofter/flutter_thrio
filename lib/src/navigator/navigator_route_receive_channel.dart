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
import 'package:thrio/src/channel/thrio_channel.dart';
import 'package:thrio/src/navigator/navigator_types.dart';

import 'navigator_logger.dart';
import 'navigator_route_settings.dart';
import 'thrio_navigator_implement.dart';

class NavigatorRouteReceiveChannel {
  NavigatorRouteReceiveChannel(ThrioChannel channel,
      Map<String, NavigatorParamsCallback> pagePoppedResults)
      : _channel = channel,
        _pagePoppedResults = pagePoppedResults {
    _onPush();
    _onPop();
    _onPopTo();
    _onRemove();
  }

  final ThrioChannel _channel;

  final Map<String, NavigatorParamsCallback> _pagePoppedResults;

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

  void _onPush() => _channel.registryMethodCall('__onPush__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        verbose('onPush: url->${routeSettings.url} '
            'index->${routeSettings.index}');
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.navigatorState
            ?.push(routeSettings, animated: animated)
            ?.then((it) {
          _clearPagePoppedResults();
          return it;
        });
      });

  void _onPop() => _channel.registryMethodCall('__onPop__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        final poppedResult = _pagePoppedResults.remove(routeSettings.name);
        if (poppedResult != null) {
          poppedResult(routeSettings.params);
        }
        return ThrioNavigatorImplement.navigatorState
            ?.maybePop(routeSettings, animated: animated)
            ?.then((it) {
          _clearPagePoppedResults();
          return it;
        });
      });

  void _onPopTo() => _channel.registryMethodCall('__onPopTo__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.navigatorState
            ?.popTo(routeSettings, animated: animated)
            ?.then((it) {
          _clearPagePoppedResults();
          return it;
        });
      });

  void _onRemove() =>
      _channel.registryMethodCall('__onRemove__', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.navigatorState
            ?.remove(routeSettings, animated: animated)
            ?.then((it) {
          _clearPagePoppedResults();
          return it;
        });
      });

  void _clearPagePoppedResults() {
    if (_pagePoppedResults.isEmpty) {
      return;
    }
    final routeHistory = ThrioNavigatorImplement.navigatorState?.history;
    if (routeHistory?.isNotEmpty ?? false) {
      _pagePoppedResults.removeWhere((name, _) =>
          routeHistory.lastWhere(
            (it) => it.settings.name == name,
            orElse: () => null,
          ) !=
          null);
    } else {
      _pagePoppedResults.clear();
    }
  }
}
