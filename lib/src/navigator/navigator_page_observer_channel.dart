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
import 'navigator_page_observer.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';

class NavigatorPageObserverChannel extends NavigatorPageObserver {
  final _channel = ThrioChannel(channel: '__thrio_page_channel__');

  @override
  void onCreate(NavigatorPageRoute route) => _channel.invokeMethod(
        'onCreate',
        route.settings.toArguments(),
      );

  @override
  void willAppear(NavigatorPageRoute route) => _channel.invokeMethod(
        'willAppear',
        route.settings.toArguments(),
      );

  @override
  void didAppear(NavigatorPageRoute route) => _channel.invokeMethod(
        'didAppear',
        route.settings.toArguments(),
      );

  @override
  void didDisappear(NavigatorPageRoute route) => _channel.invokeMethod(
        'onCreate',
        route.settings.toArguments(),
      );

  @override
  void willDisappear(NavigatorPageRoute route) => _channel.invokeMethod(
        'willDisappear',
        route.settings.toArguments(),
      );
}
