// Copyright (c) 2019/1/6, 21:48:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/widgets.dart';

import '../extension/thrio_stateful_widget.dart';
import '../navigator/thrio_navigator.dart';

class ThrioApp {
  factory ThrioApp() => _default;

  ThrioApp._();

  static final _default = ThrioApp._();

  ThrioNavigator _navigator;

  /// Assigned when the `build` method is called.
  ///
  ThrioNavigatorState get navigatorState =>
      _navigator.tryStateOf<ThrioNavigatorState>();

  TransitionBuilder build() => (context, child) => _navigator = ThrioNavigator(
        key: GlobalKey<ThrioNavigatorState>(),
        child: child is Navigator ? child : null,
      );
}
