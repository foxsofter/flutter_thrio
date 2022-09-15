import 'package:flutter_thrio/flutter_thrio.dart';

import 'biz1/biz1.g.dart';
import 'biz2/biz2.g.dart';

final home = Home._();

class Home with NavigatorRouteNode {
  Home._() {
    biz1 = Biz1(this);
    biz2 = Biz2(this);
  }

  @override
  NavigatorRouteNode get parent => emptyRoute;

  @override
  String get name => '';

  late final Biz1 biz1;

  late final Biz2 biz2;
}
