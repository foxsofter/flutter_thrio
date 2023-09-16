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

import '../navigator/navigator_page_observer.dart';
import '../registry/registry_set.dart';
import 'thrio_module.dart';

mixin ModulePageObserver on ThrioModule {
  @protected
  final pageObservers = RegistrySet<NavigatorPageObserver>();

  /// A function for register a page observer.
  ///
  @protected
  void onPageObserverRegister(ModuleContext moduleContext) {}

  /// Register observers for the life cycle of all pages under
  /// the current module and submodules.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  /// Do not override this method.
  ///
  @protected
  VoidCallback registerPageObserver(NavigatorPageObserver pageObserver) =>
      pageObservers.registry(pageObserver);
}
