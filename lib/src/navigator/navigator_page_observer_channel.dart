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

import 'package:flutter/widgets.dart';

import '../channel/thrio_channel.dart';
import 'navigator_page_observer.dart';
import 'navigator_route_settings.dart';

class NavigatorPageObserverChannel extends NavigatorPageObserver {
  NavigatorPageObserverChannel()
      : _channel = ThrioChannel(channel: '__thrio_page_channel__');

  final ThrioChannel _channel;

  @override
  void onCreate(RouteSettings settings) {
    final arguments = settings.toArguments();
    _channel.invokeMethod('onCreate', arguments);
  }

  @override
  void willAppear(RouteSettings settings) {
    final arguments = settings.toArguments();
    _channel.invokeMethod('willAppear', arguments);
  }

  @override
  void didAppear(RouteSettings settings) {
    final arguments = settings.toArguments();
    _channel.invokeMethod('didAppear', arguments);
  }

  @override
  void didDisappear(RouteSettings settings) {
    final arguments = settings.toArguments();
    _channel.invokeMethod('onCreate', arguments);
  }

  @override
  void willDisappear(RouteSettings settings) {
    final arguments = settings.toArguments();
    _channel.invokeMethod('willDisappear', arguments);
  }
}
