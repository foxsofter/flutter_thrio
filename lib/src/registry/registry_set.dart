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
    assert(values.isNotEmpty, 'values must not be null or empty');

    _sets.addAll(values);
    return () {
      _sets.removeAll(values);
    };
  }

  void clear() => _sets.clear();

  @override
  Iterator<T> get iterator => _sets.iterator;
}
