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

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

abstract class ThrioLogger {
  /// Log a message at level verbose.
  ///
  static void v(final dynamic message) => _print('V', message);

  /// Log a message at level debug.
  ///
  static void d(final dynamic message) => _print('D', message);

  /// Log a message at level info.
  ///
  static void i(final dynamic message) => _print('I', message);

  /// Log a message at level warning.
  ///
  static void w(final dynamic message) => _print('W', message);

  /// Log a message at level error.
  ///
  static void e(final dynamic message) => _print('E', message);

  static void _print(final String level, final dynamic message) =>
      debugPrint('[$level] $message');
}
