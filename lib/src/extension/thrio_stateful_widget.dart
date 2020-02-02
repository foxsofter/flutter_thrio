// Copyright (c) 2019/12/04, 17:20:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/widgets.dart';

extension ThrioStatefulWidget on StatefulWidget {
  /// Get widget state from the global key.
  ///
  T stateOf<T extends State<StatefulWidget>>() {
    if (this.key == null) {
      return null;
    }
    final key = this.key;
    if (key is GlobalKey<T>) {
      return key.currentState;
    }
    return null;
  }

  /// Get widget state from the global key.
  ///
  /// Throw `Exception` if the key is not a GlobalKey<T>.
  ///
  T tryStateOf<T extends State<StatefulWidget>>() {
    if (this.key == null) {
      return null;
    }
    final key = this.key;
    if (key is GlobalKey<T>) {
      return key.currentState;
    }
    throw Exception('${key.runtimeType} is not a GlobalKey<T>');
  }
}
