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
        final error = arguments['error'];
        v(message, error);
      })
      ..registryMethodCall('d', ([arguments]) async {
        final message = arguments['message'];
        final error = arguments['error'];
        d(message, error);
      })
      ..registryMethodCall('i', ([arguments]) async {
        final message = arguments['message'];
        final error = arguments['error'];
        d(message, error);
      })
      ..registryMethodCall('w', ([arguments]) async {
        final message = arguments['message'];
        final error = arguments['error'];
        d(message, error);
      })
      ..registryMethodCall('e', ([arguments]) async {
        final message = arguments['message'];
        final error = arguments['error'];
        final stackTrace = arguments['stackTrace'];
        if (stackTrace is String) {
          d(message, error, StackTrace.fromString(stackTrace));
        } else {
          d(message, error);
        }
      });
  }

  static ThrioLogger _default;

  /// Log a message at level verbose.
  ///
  void v(message, [error, StackTrace stackTrace]) =>
      Logger().v(message, error, stackTrace);

  /// Log a message at level [Level.debug].
  ///
  void d(message, [error, StackTrace stackTrace]) =>
      Logger().d(message, error, stackTrace);

  /// Log a message at level [Level.info].
  ///
  void i(message, [error, StackTrace stackTrace]) =>
      Logger().i(message, error, stackTrace);

  /// Log a message at level [Level.warning].
  ///
  void w(message, [error, StackTrace stackTrace]) =>
      Logger().w(message, error, stackTrace);

  /// Log a message at level [Level.error].
  ///
  void e(message, [error, StackTrace stackTrace]) =>
      Logger().e(message, error, stackTrace);
}
