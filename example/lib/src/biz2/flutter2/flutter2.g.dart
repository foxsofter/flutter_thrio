import 'package:flutter_thrio/flutter_thrio.dart';

class Flutter2 extends NavigatorRouteLeaf {
  Flutter2(NavigatorRouteNode parent) : _parent = parent;

  final NavigatorRouteNode _parent;

  @override
  NavigatorRouteNode get parent => _parent;

  @override
  String get name => 'flutter2';

  // Future<int> push<TParams>({
  //   final TParams? params,
  //   final bool animated = true,
  //   final NavigatorParamsCallback? poppedResult,
  // }) {}
}
