// The MIT License (MIT)
//
// Copyright (c) 2019 Hellobike Group
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

import 'package:flutter/foundation.dart';

import '../navigator/navigator_types.dart';
import 'module_anchor.dart';
import 'thrio_module.dart';

const String kNavigatorPageDefaultUrl = 'home';

mixin ModulePageBuilder on ThrioModule {
  NavigatorPageBuilder _pageBuilder;

  NavigatorPageBuilder get pageBuilder => _pageBuilder;

  /// If there is a ModulePageBuilder in a module, there can be no submodules.
  ///
  set pageBuilder(NavigatorPageBuilder builder) {
    _pageBuilder = builder;

    final urlComponents = <String>['/$key'];
    var parentModule = parent;
    do {
      urlComponents.insert(0, '/${parentModule.key}');
      parentModule = parentModule.parent;
    } while (parentModule != null && parentModule.key.isNotEmpty);

    anchor.allUrls.add((StringBuffer()..writeAll(urlComponents)).toString());
    if (key == kNavigatorPageDefaultUrl) {
      anchor.allUrls.add((StringBuffer()
            ..writeAll(
              urlComponents..removeLast(),
            ))
          .toString());
    }
  }

  /// A function for setting a `NavigatorPageBuilder`.
  ///
  @protected
  void onPageBuilderSetting(ModuleContext moduleContext) {}
}
