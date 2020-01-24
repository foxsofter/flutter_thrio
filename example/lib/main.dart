import 'dart:async';

import 'package:flutter/foundation.dart';
import 'src/app.dart' as app;

Future<void> main() async {
  FlutterError.onError = (details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };
  runZoned<void>(app.main);
}
