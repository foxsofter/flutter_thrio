import 'package:flutter_thrio/flutter_thrio.dart';

import 'flutter2/flutter2.g.dart';
import 'flutter4/flutter4.g.dart';

class Biz2 extends NavigatorRouteNode {
  Biz2(super.parent) {
    flutter2 = Flutter2(this);
    flutter4 = Flutter4(this);
  }

  @override
  String get name => 'biz2';

  late final Flutter2 flutter2;

  late final Flutter4 flutter4;
}
