// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'extension/stateful_widget.dart';
import 'router_channel.dart';
import 'router_container.dart';
import 'router_container_observer.dart';
import 'router_logger.dart';
import 'router_navigator_observer.dart';
import 'router_route.dart';
import 'router_route_settings.dart';

/// Callback signature of the router route that will be pushed.
///
typedef RouterRouteFactory = RouterRoute<T> Function<T>(
    RouterRouteSettings settings);

/// A widget that manages a set of child widgets with a stack discipline.
///
class RouterNavigator extends StatefulWidget {
  /// Creates a widget that maintains a stack-based history of child widgets.
  ///
  const RouterNavigator({
    Key key,
    Navigator navigator,
    this.navigatorObserver,
    this.onWillPushRoute,
    this.onDidPushRoute,
  })  : _navigator = navigator,
        super(key: key);

  final Navigator _navigator;

  final RouterNavigatorObserver navigatorObserver;

  /// Called when a route will be pushed.
  ///
  final RouterRouteFactory onWillPushRoute;

  /// Called after the route has been pushed.
  ///
  final RouterRouteFactory onDidPushRoute;

  @override
  RouterNavigatorState createState() => RouterNavigatorState();
}

/// The state for a [RouterNavigator] widget.
class RouterNavigatorState extends State<RouterNavigator> {
  final _overlayKey = GlobalKey<OverlayState>();
  final _history = <RouterContainer>[];

  RouterContainer _current;
  RouterRouteSettings _currentSettings;
  List<_RouterContainerOverlayEntry> _historyEntries;

  bool _foreground = true;

  bool get foreground => _foreground;

  RouterContainer get current => _current;

  void activate(RouterRouteSettings routeSettings) {
    if (routeSettings == _current.routeSettings) {
      return _onActivate(null, routeSettings);
    }
    final index =
        _history.indexWhere((it) => it.routeSettings == routeSettings);
    if (index > -1) {
      _history.add(_current);
      _current = _history.removeAt(index);

      setState(() {});

      RouterContainerObserver().onNavigationChanged(
        _current.routeSettings,
        RouterContainerNavigation.activate,
      );
    } else {
      push(routeSettings);
    }
  }

  void bringToFront() {
    _foreground = true;
  }

  @override
  Widget build(BuildContext context) => Overlay(
        key: _overlayKey,
        initialEntries: const <OverlayEntry>[],
      );

  @override
  void initState() {
    super.initState();

    _current = RouterContainer.copyWith(navigator: widget._navigator);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void pop() {
    if (_history.isEmpty) {
      return;
    }
    final container = _current;
    _current = _history.removeLast();

    setState(() {});

    RouterContainerObserver().onNavigationChanged(
      container.routeSettings,
      RouterContainerNavigation.pop,
    );
  }

  void push(RouterRouteSettings routeSettings) {
    assert(_history.every((it) => it.routeSettings == routeSettings));
    _history.add(_current);
    _current = RouterContainer(
        navigator: widget._navigator,
        routeSettings: routeSettings,
        observers: [widget.navigatorObserver]);

    setState(() {});

    RouterContainerObserver().onNavigationChanged(
      routeSettings,
      RouterContainerNavigation.push,
    );
  }

  void remove(RouterRouteSettings routeSettings) {
    if (_current.routeSettings == routeSettings) {
      return pop();
    }
    final container = _history.lastWhere(
        (it) => it.routeSettings == routeSettings,
        orElse: () => null);
    if (container != null) {
      _history.remove(container);
      setState(() {});
      RouterContainerObserver().onNavigationChanged(
        container.routeSettings,
        RouterContainerNavigation.remove,
      );
    }
  }

  void sendToBack() {
    _foreground = false;
  }

  @override
  void setState(VoidCallback fn) {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((duration) {
        _refreshOverlayEntries();
      });
    } else {
      _refreshOverlayEntries();
    }

    fn();
  }

  void _onActivate(
    RouterRouteSettings oldSettings,
    RouterRouteSettings currentSettings,
  ) {
    RouterLogger.v('onActivate oldSettings:$oldSettings');
    RouterLogger.v('onActivate currentSettings:$currentSettings');

    final arguments = <String, dynamic>{
      'newUrl': currentSettings.url,
      'newIndex': currentSettings.index,
      'oldUrl': oldSettings.url,
      'oldIndex': oldSettings.index,
    };

    RouterChannel().invokeMethod('onActivate', arguments);
  }

  void _refreshOverlayEntries() {
    final overlayState = _overlayKey.currentState;

    if (overlayState == null) {
      return;
    }

    if (_historyEntries?.isNotEmpty ?? false) {
      for (final it in _historyEntries) {
        it.remove();
      }
    }

    final containers = <RouterContainer>[..._history];
    assert(_current != null, 'Must contain at least one RouterContainer.');
    containers.add(_current);

    _historyEntries = containers
        .map<_RouterContainerOverlayEntry>(
            (container) => _RouterContainerOverlayEntry(container))
        .toList(growable: false);

    overlayState.insertAll(_historyEntries);

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      final currentSettings = _current.routeSettings;
      if (_currentSettings != currentSettings) {
        final old = _currentSettings;
        _currentSettings = currentSettings;
        _onActivate(old, _currentSettings);
      }
      _updateFocuse();
    });
  }

  void _updateFocuse() {
    final currentState = _current.tryStateOf<RouterContainerState>();
    if (currentState != null) {
      FocusScope.of(context).setFirstFocus(currentState.focusScopeNode);
    }
  }
}

class _RouterContainerOverlayEntry extends OverlayEntry {
  _RouterContainerOverlayEntry(RouterContainer container)
      : super(
          builder: (ctx) => container,
          opaque: true,
          maintainState: true,
        );

  var _removed = false;

  @override
  void remove() {
    assert(!_removed);

    if (_removed) {
      return;
    }

    _removed = true;
    super.remove();
  }
}
