// Copyright (c) 2019/12/02, 11:28:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../extension/stateful_widget.dart';
import '../logger/thrio_logger.dart';
import 'thrio_navigator_observer.dart';
import 'thrio_page.dart';
import 'thrio_route.dart';
import 'thrio_route_settings.dart';

/// Callback signature of the thrio route that will be pushed.
///
typedef ThrioRouteFactory = ThrioRoute<T> Function<T>(
    ThrioRouteSettings settings);

/// A widget that manages a set of child widgets with a stack discipline.
///
class ThrioNavigator extends StatefulWidget {
  /// Creates a widget that maintains a stack-based history of child widgets.
  ///
  const ThrioNavigator({
    Key key,
    Navigator navigator,
    this.navigatorObserver,
    this.onWillPushRoute,
    this.onDidPushRoute,
  })  : _navigator = navigator,
        super(key: key);

  final Navigator _navigator;

  final ThrioNavigatorObserver navigatorObserver;

  /// Called when a route will be pushed.
  ///
  final ThrioRouteFactory onWillPushRoute;

  /// Called after the route has been pushed.
  ///
  final ThrioRouteFactory onDidPushRoute;

  @override
  ThrioNavigatorState createState() => ThrioNavigatorState();
}

/// The state for a [ThrioNavigator] widget.
///
class ThrioNavigatorState extends State<ThrioNavigator> {
  final _overlayKey = GlobalKey<OverlayState>();
  final _history = <ThrioPage>[];

  ThrioPage _current;
  ThrioRouteSettings _currentSettings;
  List<_ContainerOverlayEntry> _historyEntries;

  bool _foreground = true;

  ThrioPage get current => _current;

  bool get foreground => _foreground;

  ThrioRouteFactory get onDidPushRoute => widget.onDidPushRoute;

  ThrioRouteFactory get onWillPushRoute => widget.onWillPushRoute;

  void activate(ThrioRouteSettings routeSettings) {
    if (routeSettings == _current.routeSettings) {
      return _onActivate(null, routeSettings);
    }
    final index =
        _history.indexWhere((it) => it.routeSettings == routeSettings);
    if (index > -1) {
      _history.add(_current);
      _current = _history.removeAt(index);

      setState(() {});
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

    _current = ThrioPage.copyWith(navigator: widget._navigator);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void pop() {
    if (_history.isEmpty) {
      return;
    }
    _current = _history.removeLast();

    setState(() {});
  }

  void push(ThrioRouteSettings routeSettings) {
    _history.add(_current);
    _current = ThrioPage(
        navigator: widget._navigator,
        routeSettings: routeSettings,
        observers:
            widget.navigatorObserver != null ? [widget.navigatorObserver] : []);

    setState(() {});
  }

  void remove(ThrioRouteSettings routeSettings) {
    if (_current.routeSettings == routeSettings) {
      return pop();
    }
    final container = _history.lastWhere(
        (it) => it.routeSettings == routeSettings,
        orElse: () => null);
    if (container != null) {
      _history.remove(container);
      setState(() {});
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
    ThrioRouteSettings oldSettings,
    ThrioRouteSettings currentSettings,
  ) {
    ThrioLogger().v('onActivate oldSettings:$oldSettings');
    ThrioLogger().v('onActivate currentSettings:$currentSettings');

    final arguments = <String, dynamic>{
      'newUrl': currentSettings.url,
      'newIndex': currentSettings.index,
      'oldUrl': oldSettings?.url ?? '',
      'oldIndex': oldSettings?.index ?? 0,
    };

    // ThrioChannel().invokeMethod('onActivate', arguments);
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

    final containers = <ThrioPage>[..._history];
    assert(_current != null, 'Must contain at least one Container.');
    containers.add(_current);

    _historyEntries = containers
        .map<_ContainerOverlayEntry>(
            (container) => _ContainerOverlayEntry(container))
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
    final currentState = _current.tryStateOf<ThrioPageState>();
    if (currentState != null) {
      FocusScope.of(context).setFirstFocus(currentState.focusScopeNode);
    }
  }
}

class _ContainerOverlayEntry extends OverlayEntry {
  _ContainerOverlayEntry(ThrioPage container)
      : super(
          builder: (_) => container,
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
