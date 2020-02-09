// Copyright (c) 2019/12/04, 11:38:58 PM The Hellobike. All rights reserved.
// Created by foxsofter, foxsofter@gmail.com.

import 'package:logger/logger.dart';

import '../channel/thrio_channel.dart';

class ThrioLogger {
  factory ThrioLogger() => _default ??= ThrioLogger._();

  ThrioLogger._() {
    ThrioChannel(channel: '__thrio_logger__')
      ..registryMethodCall('v', ([arguments]) async {
        final message = arguments['message'];
        var error = arguments['error'];
        if (error != null && error is String && error.isEmpty) {
          error = null;
        }
        v('[N] $message', error);
      })
      ..registryMethodCall('d', ([arguments]) async {
        final message = arguments['message'];
        var error = arguments['error'];
        if (error != null && error is String && error.isEmpty) {
          error = null;
        }
        d('[N] $message', error);
      })
      ..registryMethodCall('i', ([arguments]) async {
        final message = arguments['message'];
        var error = arguments['error'];
        if (error != null && error is String && error.isEmpty) {
          error = null;
        }
        d('[N] $message', error);
      })
      ..registryMethodCall('w', ([arguments]) async {
        final message = arguments['message'];
        var error = arguments['error'];
        if (error != null && error is String && error.isEmpty) {
          error = null;
        }
        d('[N] $message', error);
      })
      ..registryMethodCall('e', ([arguments]) async {
        final message = arguments['message'];
        var error = arguments['error'];
        if (error != null && error is String && error.isEmpty) {
          error = null;
        }
        d('[N] $message', error);
      });
  }

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
