import 'package:flutter_thrio/flutter_thrio.dart';

class Flutter3 extends NavigatorRouteLeaf {
  Flutter3(NavigatorRouteNode parent) : _parent = parent;

  final NavigatorRouteNode _parent;

  @override
  NavigatorRouteNode get parent => _parent;

  @override
  String get name => 'flutter3';
}
