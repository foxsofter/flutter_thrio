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

import 'thrio_navigator.dart';

class NavigatorRouteNode {
  NavigatorRouteNode(this.parent);

  NavigatorRouteNode.home() : this(_emptyRouteNode);

  /// parent route node
  ///
  late final NavigatorRouteNode parent;

  /// Current route node name
  ///
  String get name => '';

  String? _url;

  /// Get route url by join all route node's name.
  ///
  String get url {
    _initUrl(this);
    return _url!;
  }

  Future<bool> notify<TParams>(
    String name, {
    TParams? params,
  }) =>
      ThrioNavigator.notify(
        url: url,
        name: name,
        params: params,
      );
}

void _initUrl(NavigatorRouteNode routeNode) {
  if (routeNode._url == null) {
    var parentUrl = '';
    final parentRoute = routeNode.parent;
    if (parentRoute != _emptyRouteNode && parentRoute.name.isNotEmpty) {
      parentUrl = parentRoute.url;
    }
    routeNode._url = '$parentUrl/${routeNode.name}';
  }
}

class NavigatorRouteLeaf extends NavigatorRouteNode {
  NavigatorRouteLeaf(super.parent);

  Future<bool> popTo({bool animated = true}) =>
      ThrioNavigator.popTo(url: url, animated: animated);

  Future<bool> remove({bool animated = true}) =>
      ThrioNavigator.remove(url: url, animated: animated);

  Future<int> replace({
    required String newUrl,
  }) =>
      ThrioNavigator.replace(
        url: url,
        newUrl: newUrl,
      );
}

final EmptyNavigatorRoute _emptyRouteNode = EmptyNavigatorRoute._();

class EmptyNavigatorRoute implements NavigatorRouteNode {
  EmptyNavigatorRoute._();

  @override
  NavigatorRouteNode get parent =>
      throw UnimplementedError('Methods of this instance should not be called');
  @override
  set parent(NavigatorRouteNode parent) =>
      throw UnimplementedError('Methods of this instance should not be called');

  @override
  String get name =>
      throw UnimplementedError('Methods of this instance should not be called');

  @override
  String? _url;

  @override
  Future<bool> notify<TParams>(
    String name, {
    TParams? params,
    int index = 0,
  }) =>
      throw UnimplementedError('Methods of this instance should not be called');

  @override
  String get url =>
      throw UnimplementedError('Methods of this instance should not be called');
}
