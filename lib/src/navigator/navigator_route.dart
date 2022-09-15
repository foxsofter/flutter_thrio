// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'navigator_types.dart';
import 'thrio_navigator.dart';

mixin NavigatorRouteNode {
  /// parent route node
  ///
  NavigatorRouteNode get parent;

  /// Current route part node
  ///
  String get name;

  /// Get route url by join all route node's name.
  ///
  String get url {
    final pathComs = <String>[name];
    var parentRoute = parent;
    while (parentRoute != emptyRoute) {
      pathComs.add(parentRoute.name);
      parentRoute = parentRoute.parent;
    }
    return pathComs.reversed.join('/');
  }
}

class NavigatorRouteLeaf with NavigatorRouteNode {
  Future<int> push<TParams>({
    final TParams? params,
    final bool animated = true,
    final NavigatorParamsCallback? poppedResult,
  }) =>
      ThrioNavigator.push(
        url: url,
        params: params,
        animated: animated,
        poppedResult: poppedResult,
      );

  Future<bool> notify<TParams>(
    final String name, {
    final TParams? params,
    final int index = 0,
  }) =>
      ThrioNavigator.notify(
        url: url,
        index: index,
        name: name,
        params: params,
      );

  Future<bool> popTo({final bool animated = true}) =>
      ThrioNavigator.popTo(url: url, animated: animated);

  Future<bool> remove({final bool animated = true}) =>
      ThrioNavigator.remove(url: url, animated: animated);

  @override
  String get name => throw UnimplementedError();

  @override
  NavigatorRouteNode get parent => throw UnimplementedError();
}

final EmptyNavigatorRoute emptyRoute = EmptyNavigatorRoute._();

class EmptyNavigatorRoute with NavigatorRouteNode {
  EmptyNavigatorRoute._();

  @override
  NavigatorRouteNode get parent => emptyRoute;

  @override
  String get name => '';
}
