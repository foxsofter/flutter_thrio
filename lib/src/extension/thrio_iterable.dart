// The MIT License (MIT)
//
// Copyright (c) 2021 foxsofter.
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

extension ThrioIterable<E> on Iterable<E> {
  /// Returns the first element.
  ///
  /// Return `null` if `this` is empty.
  /// Otherwise returns the first element in the iteration order,
  ///
  E? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element.
  ///
  /// Return `null` if `this` is empty.
  /// Otherwise may iterate through the elements and returns the last one
  /// seen.
  E? get lastOrNull => isEmpty ? null : last;

  /// Returns the first element that satisfies the given [predicate].
  ///
  /// If no element satisfies [test], return `null`.
  ///
  E? firstWhereOrNull(final bool Function(E it) predicate) {
    for (final it in this) {
      if (predicate(it)) {
        return it;
      }
    }
    return null;
  }

  /// Returns the last element that satisfies the given [predicate].
  ///
  /// If no element satisfies [test], return `null`.
  ///
  E? lastWhereOrNull(final bool Function(E it) predicate) {
    final reversed = toList().reversed;
    for (final it in reversed) {
      if (predicate(it)) {
        return it;
      }
    }
    return null;
  }
}
