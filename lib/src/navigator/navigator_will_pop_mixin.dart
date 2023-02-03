// The MIT License (MIT)
//
// Copyright (c) 2023 foxsofter.
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

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'navigator_page_lifecycle_mixin.dart';

/// Handle a callback to veto attempts by the user to dismiss the enclosing
/// [ModalRoute].
///
mixin NavigatorWillPopMixin<T extends StatefulWidget>
    on NavigatorPageLifecycleMixin<T> {
  /// Called to veto attempts by the user to dismiss the enclosing [ModalRoute].
  ///
  Future<bool> onWillPop() => Future.value(true);

  late final _didPopObserver = _DidPopObserver(this);

  @override
  void didAppear(final RouteSettings settings) {
    super.didAppear(settings);
    WidgetsBinding.instance.addObserver(_didPopObserver);
  }

  @override
  void didDisappear(final RouteSettings settings) {
    super.didDisappear(settings);
    WidgetsBinding.instance.removeObserver(_didPopObserver);
  }
}

class _DidPopObserver extends WidgetsBindingObserver {
  _DidPopObserver(this._delegate);

  final NavigatorWillPopMixin _delegate;

  @override
  Future<bool> didPopRoute() => _delegate.onWillPop();
}