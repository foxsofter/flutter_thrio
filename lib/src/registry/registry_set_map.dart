// Copyright (c) 2019/12/03, 13:34:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:flutter/foundation.dart';

class RegistrySetMap<K, V> {
  final Map<K, Set<V>> _maps = {};

  VoidCallback registry(K key, V value) {
    assert(key != null, 'key must not be null.');
    assert(value != null, 'value must not be null.');

    _maps[key] ??= <V>{};
    _maps[key].add(value);
    return () {
      _maps[key]?.remove(value);
      if (_maps[key]?.isEmpty ?? true) {
        _maps.remove(key);
      }
    };
  }

  VoidCallback registryAll(Map<K, V> values) {
    assert(values?.isNotEmpty ?? false, 'values must not be null or empty.');

    for (final key in values.keys) {
      _maps[key] ??= <V>{};
      _maps[key].add(values[key]);
    }
    return () {
      for (final key in values.keys) {
        _maps[key]?.remove(values[key]);
        if (_maps[key]?.isEmpty ?? true) {
          _maps.remove(key);
        }
      }
    };
  }

  Iterable<K> get keys => _maps.keys;

  Iterable<Set<V>> get values => _maps.values;

  void clear() => _maps.clear();

  Set<V> operator [](K key) => _maps[key];
}
