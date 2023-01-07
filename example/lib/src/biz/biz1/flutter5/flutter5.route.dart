// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

import 'package:flutter_thrio/flutter_thrio.dart';

class Flutter5Route extends NavigatorRouteLeaf {
  factory Flutter5Route(final NavigatorRouteNode parent) =>
      _instance ??= Flutter5Route._(parent);

  Flutter5Route._(super.parent);

  static Flutter5Route? _instance;

  @override
  String get name => 'flutter5';

  Future<TPopParams?> push<TParams, TPopParams>({
    final TParams? params,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.push<TParams, TPopParams>(
        url: url,
        params: params,
        animated: animated,
        result: result,
      );
}