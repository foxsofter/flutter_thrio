import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter1/flutter1.g.dart';
import 'flutter3/flutter3.g.dart';

class Biz1 with NavigatorRouteNode {
  Biz1(NavigatorRouteNode parent) : _parent = parent {
    flutter1 = Flutter1(this);
    flutter3 = Flutter3(this);
  }

  final NavigatorRouteNode _parent;

  @override
  NavigatorRouteNode get parent => _parent;

  @override
  String get name => 'biz1';

  late final Flutter1 flutter1;

  late final Flutter3 flutter3;
}
