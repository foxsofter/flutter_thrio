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

import 'package:logger/logger.dart';

class ThrioLogger {
  factory ThrioLogger() => _default ??= ThrioLogger._();

  ThrioLogger._();

  static ThrioLogger _default;

  final _printer = SimplePrinter(printTime: true);

  /// Log a message at level verbose.
  ///
  void v(message, [error, StackTrace stackTrace]) =>
      Logger(printer: _printer).v(message, error, stackTrace);

  /// Log a message at level [Level.debug].
  ///
  void d(message, [error, StackTrace stackTrace]) =>
      Logger(printer: _printer).d(message, error, stackTrace);

  /// Log a message at level [Level.info].
  ///
  void i(message, [error, StackTrace stackTrace]) =>
      Logger(printer: _printer).i(message, error, stackTrace);

  /// Log a message at level [Level.warning].
  ///
  void w(message, [error, StackTrace stackTrace]) =>
      Logger(printer: _printer).w(message, error, stackTrace);

  /// Log a message at level [Level.error].
  ///
  void e(message, [error, StackTrace stackTrace]) =>
      Logger(printer: _printer).e(message, error, stackTrace);
}
