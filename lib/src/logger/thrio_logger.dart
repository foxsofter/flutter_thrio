// Copyright (c) 2019/12/04, 11:38:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

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
