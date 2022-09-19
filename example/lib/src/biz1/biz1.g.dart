import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter1/flutter1.g.dart';
import 'flutter3/flutter3.g.dart';

class Biz1 extends NavigatorRouteNode {
  Biz1(super.parent) {
    flutter1 = Flutter1(this);
    flutter3 = Flutter3(this);
  }

  @override
  String get name => 'biz1';

  late final Flutter1 flutter1;

  late final Flutter3 flutter3;
}
