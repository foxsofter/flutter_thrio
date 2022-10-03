import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter2/flutter2.g.dart';
import 'flutter4/flutter4.g.dart';

class Biz2 extends NavigatorRouteNode {
  factory Biz2(final NavigatorRouteNode parent) => _instance;

  static final _instance = Biz2._(final NavigatorRouteNode parent);

  const Biz2._(final super.parent) {
    flutter2 = const Flutter2(this);
    flutter4 = const Flutter4(this);
  }

  @override
  String get name => 'biz2';

  late final Flutter2 flutter2;

  late final Flutter4 flutter4;
}
