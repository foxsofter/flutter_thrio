// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../navigator/thrio_navigator.dart';
import 'navigator_page_route.dart';
import 'navigator_route_settings.dart';
import 'navigator_types.dart';

class NavigatorPageNotify extends StatefulWidget {
  const NavigatorPageNotify({
    Key key,
    @required this.name,
    @required this.onPageNotify,
    this.initialParams,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final String name;

  final NavigatorPageNotifyCallback onPageNotify;

  final Map<String, dynamic> initialParams;

  final Widget child;

  @override
  _NavigatorPageNotifyState createState() => _NavigatorPageNotifyState();
}

class _NavigatorPageNotifyState extends State<NavigatorPageNotify> {
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
