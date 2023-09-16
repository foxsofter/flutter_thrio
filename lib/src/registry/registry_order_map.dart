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
  final _list = <MapEntry<K, V>>[];

  VoidCallback registry(K key, V value) {
    assert(key != null, 'key must not be null.');
    assert(value != null, 'value must not be null.');
    final item = MapEntry(key, value);
    _list.add(item);
    return () {
      _list.remove(item);
    };
  }

  int get length => _list.length;

  MapEntry<K, V> elementAt(int index) => _list.elementAt(index);

  Iterable<K> get keys => _list.map((it) => it.key);

  Iterable<V> get values => _list.map((it) => it.value);

  V first([final K? key]) => key == null
      ? _list.first.value
      : _list.firstWhere((it) => it.key == key).value;

  V? firstOrNull([final K? key]) => key == null
      ? _list.firstOrNull?.value
      : _list.firstWhereOrNull((it) => it.key == key)?.value;

  V firstWhere(bool Function(K k) predicate) =>
      _list.firstWhere((it) => predicate(it.key)).value;

  V? firstWhereOrNull(bool Function(K k) predicate) =>
      _list.firstWhereOrNull((it) => predicate(it.key))?.value;

  Iterable<V> where(bool Function(K k) predicate) =>
      _list.where((it) => predicate(it.key)).map((it) => it.value);

  V last([final K? key]) => key == null
      ? _list.last.value
      : _list.lastWhere((it) => it.key == key).value;

  V? lastOrNull([final K? key]) => key == null
      ? _list.lastOrNull?.value
      : _list.lastWhereOrNull((it) => it.key == key)?.value;

  V lastWhere(bool Function(K k) predicate) =>
      _list.lastWhere((it) => predicate(it.key)).value;

  V? lastWhereOrNull(bool Function(K k) predicate) =>
      _list.lastWhereOrNull((it) => predicate(it.key))?.value;

  void clear() => _list.clear();

  Iterable<V> operator [](K key) =>
      _list.where((it) => it.key == key).map((it) => it.value);
}
