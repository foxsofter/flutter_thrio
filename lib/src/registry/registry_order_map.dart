// The MIT License (MIT)
//
// Copyright (c) 2020 foxsofter
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
import '../extension/thrio_iterable.dart';

class RegistryOrderMap<K, V> {
  final _maps = <MapEntry<K, V>>[];

  VoidCallback registry(final K key, final V value) {
    assert(key != null, 'key must not be null.');
    assert(value != null, 'value must not be null.');
    final item = MapEntry(key, value);
    _maps.add(item);
    return () {
      _maps.remove(item);
    };
  }

  Iterable<K> get keys => _maps.map((final it) => it.key);

  Iterable<V> get values => _maps.map((final it) => it.value);

  V first([final K? key]) => key == null
      ? _maps.first.value
      : _maps.firstWhere((final it) => it.key == key).value;

  V? firstOrNull([final K? key]) => key == null
      ? _maps.firstOrNull?.value
      : _maps.firstWhereOrNull((final it) => it.key == key)?.value;

  V firstWhere(final bool Function(K k) predicate) =>
      _maps.firstWhere((final it) => predicate(it.key)).value;

  V? firstWhereOrNull(final bool Function(K k) predicate) =>
      _maps.firstWhereOrNull((final it) => predicate(it.key))?.value;

  Iterable<V> where(final bool Function(K k) predicate) =>
      _maps.where((final it) => predicate(it.key)).map((final it) => it.value);

  V last([final K? key]) => key == null
      ? _maps.last.value
      : _maps.lastWhere((final it) => it.key == key).value;

  V? lastOrNull([final K? key]) => key == null
      ? _maps.lastOrNull?.value
      : _maps.lastWhereOrNull((final it) => it.key == key)?.value;

  V lastWhere(final bool Function(K k) predicate) =>
      _maps.lastWhere((final it) => predicate(it.key)).value;

  V? lastWhereOrNull(final bool Function(K k) predicate) =>
      _maps.lastWhereOrNull((final it) => predicate(it.key))?.value;

  void clear() => _maps.clear();

  Iterable<V> operator [](final K key) =>
      _maps.where((final it) => it.key == key).map((final it) => it.value);
}
