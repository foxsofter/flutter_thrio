// Copyright (c) 2019/12/04, 17:36:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/widgets.dart';

extension BuildContextX on BuildContext {
  /// Get widget state by ancestorStateOfType method.
  ///
  /// Throw `Exception` if the `state.runtimeType` is not a T.
  ///
  T stateOf<T extends State<StatefulWidget>>() {
    final state = findAncestorStateOfType<T>();
    if (state != null && state is T) {
      return state;
    }
    throw Exception('${state.runtimeType} is not a $T');
  }

  /// Get widget state by ancestorStateOfType method.
  ///
  T tryStateOf<T extends State<StatefulWidget>>() {
    final state = findAncestorStateOfType<T>();
    if (state != null && state is T) {
      return state;
    }
    return null;
  }
}
