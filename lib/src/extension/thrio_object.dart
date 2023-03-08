// The MIT License (MIT)
//
// Copyright (c) 2021 foxsofter
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

extension ThrioObject on Object {
  /// Determine whether the current instance is a bool.
  ///
  /// Can be called in the following ways,
  /// `true.isDouble`
  /// `false.runtimeType.isDouble`
  ///
  bool get isBool {
    if (this is Type) {
      return this == bool;
    } else {
      return this is bool;
    }
  }

  /// Determine whether the current instance is an int.
  ///
  /// Can be called in the following ways,
  /// `2.isInt`
  /// `2.runtimeType.isInt`
  ///
  bool get isInt {
    if (this is Type) {
      return this == int;
    } else {
      return this is int;
    }
  }

  /// Determine whether the current instance is a double.
  ///
  /// Can be called in the following ways,
  /// `2.0.isDouble`
  /// `2.0.runtimeType.isDouble`
  ///
  bool get isDouble {
    if (this is Type) {
      return this == double;
    } else {
      return this is double;
    }
  }

  /// Determine whether the current instance is an int or double.
  ///
  /// Can be called in the following ways,
  /// `2.isNumber`
  /// `2.0.runtimeType.isNumber`
  ///
  bool get isNumber {
    if (this is Type) {
      return this == double || this == int;
    } else {
      return this is num;
    }
  }

  /// Determine whether the current instance is a String.
  ///
  /// Can be called in the following ways,
  /// `'2'.isString`
  /// `'2'.runtimeType.isString`
  ///
  bool get isString {
    if (this is Type) {
      return this == String;
    } else {
      return this is String;
    }
  }

  /// Determine whether the current instance is a List.
  ///
  /// Can be called in the following ways,
  /// `[ 'k', '2' ].isString`
  /// `[ 'k', '2' ].runtimeType.isString`
  ///
  bool get isList {
    if (this is Type) {
      return toString().contains('List');
    } else {
      return this is List;
    }
  }

  /// Determine whether the current instance is a simple List.
  ///
  /// Can be called in the following ways,
  /// `[ 'k', '2' ].isString`
  ///
  bool get isSimpleList {
    final ts = this;
    if (ts is! List) {
      return false;
    }
    for (final it in ts) {
      if (it is Object && it.isSimpleType == false) {
        return false;
      }
    }
    return true;
  }

  /// Determine whether the current instance is a Map.
  ///
  /// Can be called in the following ways,
  /// `{ 'k': 2 }.isMap`
  /// `{ 'k': 2 }.runtimeType.isMap`
  ///
  bool get isMap {
    if (this is Type) {
      return toString().contains('Map');
    } else {
      return this is Map;
    }
  }

  /// Determine whether the current instance is a simple Map.
  ///
  /// Can be called in the following ways,
  /// `{ 'k': 2 }.isMap`
  ///
  bool get isSimpleMap {
    final ts = this;
    if (ts is! Map) {
      return false;
    }
    for (final it in ts.values) {
      if (it is Object && it.isSimpleType == false) {
        return false;
      }
    }
    return true;
  }

  /// Determine whether the current instance is a primitive type,
  /// including bool, int, double, String.
  ///
  /// Can be called in the following ways,
  /// `2.isPrimitiveType`
  /// `2.runtimeType.isPrimitiveType`
  ///
  bool get isPrimitiveType {
    if (this is Type) {
      return this == bool || this == int || this == double || this == String;
    } else {
      return this is bool || this is num || this is String;
    }
  }

  /// Determine whether the current instance is a simple type,
  /// including bool, int, double, String, Map, List.
  ///
  /// Can be called in the following ways,
  /// `2.isSimpleType`
  ///
  bool get isSimpleType => isPrimitiveType || isSimpleList || isSimpleMap;

  /// Determine whether the current instance is a complex type,
  /// not bool, int, double, String, Map, List.
  ///
  /// Can be called in the following ways,
  /// `2.isComplexType`
  ///
  bool get isComplexType => !isSimpleType;
}
