// Copyright (c) 2019/12/04, 11:38:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:logger/logger.dart';

class RouterLogger {
  RouterLogger._();

  /// Log a message at level verbose.
  ///
  static void v(message, [error, StackTrace stackTrace]) =>
      Logger().v(message, error, stackTrace);

  /// Log a message at level [Level.debug].
  ///
  static void d(message, [error, StackTrace stackTrace]) =>
      Logger().d(message, error, stackTrace);

  /// Log a message at level [Level.info].
  ///
  static void i(message, [error, StackTrace stackTrace]) =>
      Logger().i(message, error, stackTrace);

  /// Log a message at level [Level.warning].
  ///
  static void w(message, [error, StackTrace stackTrace]) =>
      Logger().w(message, error, stackTrace);

  /// Log a message at level [Level.error].
  ///
  static void e(message, [error, StackTrace stackTrace]) =>
      Logger().e(message, error, stackTrace);
}
