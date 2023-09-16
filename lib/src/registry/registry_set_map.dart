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

import 'package:flutter/foundation.dart';

class RegistrySetMap<K, V> {
  final Map<K, Set<V>> _maps = {};

  VoidCallback registry(K key, V value) {
    assert(key != null, 'key must not be null.');
    assert(value != null, 'value must not be null.');

    _maps[key] ??= <V>{};
    _maps[key]?.add(value);
    return () {
      _maps[key]?.remove(value);
      if (_maps[key]?.isEmpty ?? true) {
        _maps.remove(key);
      }
    };
  }

  VoidCallback registryAll(Map<K, V> values) {
    assert(values.isNotEmpty, 'values must not be null or empty.');

    for (final key in values.keys) {
      _maps[key] ??= <V>{};
      final value = values[key];
      if (value != null) {
        _maps[key]?.add(value);
      }
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

  Set<V> operator [](K key) => _maps[key] ?? <V>{};
}
