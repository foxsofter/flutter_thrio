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

import '../channel/thrio_channel.dart';
import '../module/module_anchor.dart';
import '../module/module_types.dart';
import '../module/thrio_module.dart';
import 'navigator_logger.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';
import 'thrio_navigator_implement.dart';

class NavigatorRouteReceiveChannel {
  NavigatorRouteReceiveChannel(ThrioChannel channel) : _channel = channel {
    _onPush();
    _onMaybePop();
    _onPop();
    _onPopTo();
    _onRemove();
    _onReplace();
    _onCanPop();
  }

  final ThrioChannel _channel;

  void _onPush() =>
      _channel.registryMethodCall('push', ([final arguments]) async {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings == null) {
          return false;
        }
        verbose(
          'push: url->${routeSettings.url} '
          'index->${routeSettings.index}',
        );
        routeSettings.params =
            _deserializeParams(routeSettings.url, routeSettings.params);
        final animated = arguments?['animated'] == true;
        final handlers = anchor.pushHandlers;
        for (final handler in handlers) {
          final result = await handler(routeSettings, animated: animated);
          if (result == NavigatorRoutePushHandleType.prevention) {
            return false;
          }
        }
        return await ThrioNavigatorImplement.shared()
                .navigatorState
                ?.push(routeSettings, animated: animated)
                .then((value) {
              ThrioNavigatorImplement.shared().syncPagePoppedResults();
              return value;
            }) ??
            false;
      });

  void _onMaybePop() =>
      _channel.registryMethodCall('maybePop', ([final arguments]) async {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings == null) {
          return 0;
        }
        final animated = arguments?['animated'] == true;
        final inRoot = arguments?['inRoot'] == true;
        return await ThrioNavigatorImplement.shared()
                .navigatorState
                ?.maybePop(routeSettings, animated: animated, inRoot: inRoot)
                .then((value) {
              ThrioNavigatorImplement.shared().syncPagePoppedResults();
              return value;
            }) ??
            0;
      });

  void _onPop() =>
      _channel.registryMethodCall('pop', ([final arguments]) async {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings == null) {
          return false;
        }
        final animated = arguments?['animated'] == true;
        final inRootValue = arguments != null ? arguments['inRoot'] : null;
        final inRoot =
            (inRootValue != null && inRootValue is bool) && inRootValue;
        return await ThrioNavigatorImplement.shared()
                .navigatorState
                ?.pop(routeSettings, animated: animated, inRoot: inRoot)
                .then((value) {
              ThrioNavigatorImplement.shared().syncPagePoppedResults();
              return value;
            }) ??
            false;
      });

  void _onCanPop() =>
      _channel.registryMethodCall('canPop', ([final arguments]) async {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings == null) {
          return false;
        }
        final inRoot = arguments?['inRoot'] == true;
        return await ThrioNavigatorImplement.shared()
                .navigatorState
                ?.canPop(routeSettings, inRoot: inRoot) ??
            false;
      });

  void _onPopTo() =>
      _channel.registryMethodCall('popTo', ([final arguments]) async {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings == null) {
          return false;
        }
        final animated = arguments?['animated'] == true;
        return await ThrioNavigatorImplement.shared()
                .navigatorState
                ?.popTo(routeSettings, animated: animated)
                .then((value) {
              ThrioNavigatorImplement.shared().syncPagePoppedResults();
              return value;
            }) ??
            false;
      });

  void _onRemove() =>
      _channel.registryMethodCall('remove', ([final arguments]) async {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings == null) {
          return false;
        }
        final animated = arguments?['animated'] == true;
        return await ThrioNavigatorImplement.shared()
                .navigatorState
                ?.remove(routeSettings, animated: animated)
                .then((value) {
              ThrioNavigatorImplement.shared().syncPagePoppedResults();
              return value;
            }) ??
            false;
      });

  void _onReplace() =>
      _channel.registryMethodCall('replace', ([final arguments]) async {
        final routeSettings = NavigatorRouteSettings.fromArguments(arguments);
        if (routeSettings == null) {
          return false;
        }
        final newRouteSettings =
            NavigatorRouteSettings.fromNewUrlArguments(arguments);
        if (newRouteSettings == null) {
          return false;
        }
        return await ThrioNavigatorImplement.shared()
                .navigatorState
                ?.replace(routeSettings, newRouteSettings)
                .then((value) {
              ThrioNavigatorImplement.shared().syncPagePoppedResults();
              return value;
            }) ??
            false;
      });

  Stream<dynamic> onPageNotify({
    required String name,
    String? url,
    int index = 0,
  }) =>
      _channel
          .onEventStream('__onNotify__')
          .where((arguments) =>
              arguments.containsValue(name) &&
              (url == null || url.isEmpty || arguments.containsValue(url)) &&
              (index == 0 || arguments.containsValue(index)))
          .map((arguments) => arguments['params']);

  dynamic _deserializeParams(String url, dynamic params) {
    if (params == null) {
      return null;
    }

    if (params is Map) {
      if (params.containsKey('__thrio_Params_HashCode__')) {
        // ignore: avoid_as
        return anchor
            .removeParam<dynamic>(params['__thrio_Params_HashCode__'] as int);
      }

      if (params.containsKey('__thrio_TParams__')) {
        // ignore: avoid_as
        final typeString = params['__thrio_TParams__'] as String;
        if (typeString.isNotEmpty) {
          final paramsObj = ThrioModule.get<JsonDeserializer<dynamic>>(
                  url: url, key: typeString)
              ?.call(params.cast<String, dynamic>());
          if (paramsObj != null) {
            return paramsObj;
          }
        }
      }
    }

    return params;
  }
}
