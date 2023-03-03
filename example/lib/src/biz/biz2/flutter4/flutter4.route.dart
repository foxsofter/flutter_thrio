// Copyright (c) 2023 foxsofter.
//
// Do not edit this file.
//

import 'package:example/src/biz/types/people.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

class Flutter4Route extends NavigatorRouteLeaf {
  factory Flutter4Route(final NavigatorRouteNode parent) =>
      _instance ??= Flutter4Route._(parent);

  Flutter4Route._(super.parent);

  static Flutter4Route? _instance;

  @override
  String get name => 'flutter4';

  /// `people` hello, this is a people
  ///
  /// 打开 people 页面
  ///
  Future<TPopParams?> push<TPopParams>({
    required final People people,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.push<Map<String, dynamic>, TPopParams>(
        url: url,
        params: <String, dynamic>{
          'people': people,
        },
        animated: animated,
        result: result,
      );

  /// `people` hello, this is a people
  ///
  /// 打开 people 页面
  ///
  Future<TPopParams?> pushSingle<TPopParams>({
    required final People people,
    final bool animated = true,
    final NavigatorIntCallback? result,
  }) =>
      ThrioNavigator.pushSingle<Map<String, dynamic>, TPopParams>(
        url: url,
        params: <String, dynamic>{
          'people': people,
        },
        animated: animated,
        result: result,
      );
}
