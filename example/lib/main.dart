import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

import 'src/app.dart' as app;

Future<void> main() async {
  ThrioLogger.v('main');
  FlutterError.onError = (details) async {
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };
  runZoned<void>(app.main);
}

@pragma('vm:entry-point')
Future<void> biz1() async {
  FlutterError.onError = (details) async {
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };
  runZoned<void>(app.biz1);
}

@pragma('vm:entry-point')
Future<void> biz2() async {
  FlutterError.onError = (details) async {
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };
  runZoned<void>(app.biz2);
}
