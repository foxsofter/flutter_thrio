// The MIT License (MIT)
//
// Copyright (c) 2023 foxsofter
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

import 'thrio_object.dart';

extension ThrioList<E> on List<E> {
  /// Filter the elements of the current map, keeping only simple types.
  ///
  List<E> toSimpleList() {
    final list = <E>[];
    final ts = this;
    for (final e in ts) {
      if (e?.isSimpleType == true) {
        list.add(e);
      }
    }
    return list;
  }

  bool compareTo(List<E> other, bool Function(E a, E b) test) {
    if (other.length != length) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    for (var index = 0; index < other.length; index += 1) {
      if (!test(this[index], other[index])) {
        return false;
      }
    }
    return true;
  }
}
