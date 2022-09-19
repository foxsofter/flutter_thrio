import 'package:flutter_thrio/flutter_thrio.dart';

import 'biz1/biz1.g.dart';
import 'biz2/biz2.g.dart';

final root = _Home._();

class _Home extends NavigatorRouteNode {
  _Home._() : super.home();

  @override
  String get name => '';

  final Biz1 biz1 = Biz1(root);

  final Biz2 biz2 = Biz2(root);
}
