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

mixin ModulePageBuilder on ThrioModule {
  NavigatorPageBuilder? _pageBuilder;

  NavigatorPageBuilder? get pageBuilder => _pageBuilder;

  /// If there is a ModulePageBuilder in a module, there can be no submodules.
  ///
  set pageBuilder(final NavigatorPageBuilder? builder) {
    _pageBuilder = builder;

    final urlComponents = <String>['/$key'];
    var parentModule = parent;
    while (parentModule != null && parentModule.key.isNotEmpty) {
      urlComponents.insert(0, '/${parentModule.key}');
      parentModule = parentModule.parent;
    }
    final url = (StringBuffer()..writeAll(urlComponents)).toString();
    if (builder == null) {
      anchor.allUrls.remove(url);
    } else {
      anchor.allUrls.add(url);
    }
  }

  /// A function for setting a `NavigatorPageBuilder`.
  ///
  @protected
  void onPageBuilderSetting(final ModuleContext moduleContext) {}
}
