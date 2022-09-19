import 'package:flutter_thrio/flutter_thrio.dart';

import 'biz1/biz1.g.dart';
import 'biz2/biz2.g.dart';

final root = _Home._();

class _Home extends NavigatorRouteNode {
  _Home._() : super.home() {
    biz1 = Biz1(this);
    biz2 = Biz2(this);
  }

  @override
  String get name => '';

  late final Biz1 biz1;

  late final Biz2 biz2;
}
