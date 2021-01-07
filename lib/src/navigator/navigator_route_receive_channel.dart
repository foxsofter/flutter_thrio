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
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
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
        routeSettings.params = _deserializeParams(
          routeSettings.url,
          routeSettings.params,
        );
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        return ThrioNavigatorImplement.shared()
            .navigatorState
            ?.push(routeSettings, animated: animated)
            ?.then((value) {
          _syncPagePoppedResults();
          return value;
        });
      });

  void _onPop() => _channel.registryMethodCall('pop', ([arguments]) {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        final animatedValue = arguments['animated'];
        final animated =
            (animatedValue != null && animatedValue is bool) && animatedValue;
        final inRootValue = arguments['inRoot'];
        final inRoot =
            (inRootValue != null && inRootValue is bool) && inRootValue;
        return ThrioNavigatorImplement.shared()
            .navigatorState
            ?.maybePop(routeSettings, animated: animated, inRoot: inRoot)
            ?.then((value) {
          _syncPagePoppedResults();
          return value;
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
            ?.then((value) {
          _syncPagePoppedResults();
          return value;
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
            ?.then((value) {
          _syncPagePoppedResults();
          return value;
        });
      });

  Stream onPageNotify({
    @required String name,
    String url,
    int index,
  }) =>
      _channel
          .onEventStream('__onNotify__')
          .where((arguments) =>
              arguments.containsValue(name) &&
              (url == null || arguments.containsValue(url)) &&
              (index == null || arguments.containsValue(index)))
          .map((arguments) => arguments['params']);

  dynamic _deserializeParams(String url, dynamic params) {
    if (params == null) {
      return null;
    }

    if (params is Map) {
      if (params.containsKey('__thrio_Params_HashCode__')) {
        // ignore: avoid_as
        return anchor.removeParam(params['__thrio_Params_HashCode__'] as int);
      }

      // ignore: avoid_as
      final typeString = params['__thrio_TParams__'] as String;
      if (typeString?.isNotEmpty ?? false) {
        final paramsInstance =
            ThrioModule.get<JsonDeserializer>(url: url, key: typeString)
                ?.call(params.cast<String, dynamic>());
        if (paramsInstance != null) {
          return paramsInstance;
        }
      }
    }

    return params;
  }

  Future<void> _syncPagePoppedResults() async {
    if (ThrioNavigatorImplement.shared().poppedResults.isEmpty) {
      return;
    }
    final routes = await ThrioNavigatorImplement.shared().allRoutes();
    if (routes?.isEmpty ?? true) {
      ThrioNavigatorImplement.shared().poppedResults.clear();
    }
    ThrioNavigatorImplement.shared()
        .poppedResults
        .removeWhere((name, _) => !routes.any((it) => it.name == name));
  }
}
