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

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../navigator/thrio_navigator.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';

class ThrioPageNotify extends StatefulWidget {
  const ThrioPageNotify({
    Key key,
    @required this.name,
    @required this.onPageNotify,
    this.initialParams,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final String name;

  final ThrioPageNotifyCallback onPageNotify;

  final Map<String, dynamic> initialParams;

  final Widget child;

  @override
  _ThrioPageNotifyState createState() => _ThrioPageNotifyState();
}

class _ThrioPageNotifyState extends State<ThrioPageNotify> {
  NavigatorPageRoute _route;

  Stream<Map<String, dynamic>> _notifyStream;

  StreamSubscription<Map<String, dynamic>> _notifySubscription;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      if (widget.initialParams != null) {
        widget.onPageNotify(widget.initialParams);
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (widget.onPageNotify != null) {
      _notifySubscription?.cancel();
    }
    final route = ModalRoute.of(context);
    if (route != null && route is NavigatorPageRoute) {
      _route = route;
      _notifyStream = ThrioNavigator.onPageNotify(
        url: _route.settings.url,
        index: _route.settings.index,
        name: widget.name,
      );
      _notifySubscription = _notifyStream.listen(widget.onPageNotify);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (widget.onPageNotify != null) {
      _notifySubscription?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
