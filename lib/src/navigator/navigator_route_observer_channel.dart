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
import '../navigator/navigator_page_route.dart';
import 'navigator_route_observer.dart';
import 'navigator_route_settings.dart';

class NavigatorRouteObserverChannel with NavigatorRouteObserver {
  final _channel = ThrioChannel(channel: '__thrio_route_channel__');

  @override
  void didPush(NavigatorPageRoute route, NavigatorPageRoute previousRoute) =>
      _channel.invokeMethod<bool>(
        'didPush',
        _toArguments(route, previousRoute),
      );

  @override
  void didPop(NavigatorPageRoute route, NavigatorPageRoute previousRoute) =>
      _channel.invokeMethod<bool>(
        'didPop',
        _toArguments(route, previousRoute),
      );

  @override
  void didPopTo(NavigatorPageRoute route, NavigatorPageRoute previousRoute) =>
      _channel.invokeMethod<bool>(
        'didPopTo',
        _toArguments(route, previousRoute),
      );

  @override
  void didRemove(NavigatorPageRoute route, NavigatorPageRoute previousRoute) =>
      _channel.invokeMethod<bool>(
        'didPush',
        _toArguments(route, previousRoute),
      );

  Map<String, dynamic> _toArguments(
    NavigatorPageRoute route,
    NavigatorPageRoute previousRoute,
  ) =>
      previousRoute == null
          ? <String, dynamic>{
              'route': {
                'url': route.settings.url,
                'index': route.settings.index,
              },
            }
          : <String, dynamic>{
              'route': {
                'url': route.settings.url,
                'index': route.settings.index,
              },
              'previousRoute': {
                'url': previousRoute.settings.url,
                'index': previousRoute.settings.index,
              },
            };
}
