// Copyright (c) 2019/12/03, 11:36:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'dart:collection';
import 'package:flutter/foundation.dart';

// ignore: prefer_mixin
class RegistrySet<T> with IterableMixin<T> {
  final Set<T> _sets = {};

  VoidCallback registry(T value) {
    assert(value != null, 'value must not be null.');

    _sets.add(value);
    return () {
      _sets.remove(value);
    };
  }

  VoidCallback registryAll(Set<T> values) {
    assert(values?.isNotEmpty ?? false, 'values must not be null or empty');

    _sets.addAll(values);
    return () {
      _sets.removeAll(values);
    };
  }

  void clear() => _sets.clear();

  @override
  Iterator<T> get iterator => _sets.iterator;
}
