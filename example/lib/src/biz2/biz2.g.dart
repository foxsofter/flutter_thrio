import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter2/flutter2.g.dart';
import 'flutter4/flutter4.g.dart';

class Biz2 with NavigatorRouteNode {
  Biz2(NavigatorRouteNode parent) : _parent = parent {
    flutter2 = Flutter2(this);
    flutter4 = Flutter4(this);
  }

  final NavigatorRouteNode _parent;

  @override
  NavigatorRouteNode get parent => _parent;

  @override
  String get name => 'biz2';

  late final Flutter2 flutter2;

  late final Flutter4 flutter4;
}
