// The MIT License (MIT)
//
// Copyright (c) 2020 foxsofter
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

import '../exception/thrio_exception.dart';
import '../registry/registry_map.dart';
import 'module_anchor.dart';
import 'thrio_module.dart';

mixin ModuleParamScheme on ThrioModule {
  /// Param schemes registered in the current Module
  ///
  final _paramSchemes = RegistryMap<Comparable, Type>();

  final _params = <Comparable, dynamic>{};

  /// Gets param by `key` & `T`.
  ///
  /// Throw `ThrioException` if `T` is not matched param scheme.
  ///
  @protected
  T getParam<T>(Comparable key) {
    // Anchor module does not need to get param scheme.
    if (this == anchor) {
      return _params[key] as T; // ignore: avoid_as
    }
    if (T != dynamic &&
        _paramSchemes.keys.contains(key) &&
        _paramSchemes[key] != T) {
      throw ThrioException(
        '$T does not match the param scheme type: ${_paramSchemes[key]}',
      );
    }
    return _params[key] as T; // ignore: avoid_as
  }

  /// Sets param with `key` & `value`.
  ///
  /// Return `false` if param scheme is not registered.
  ///
  @protected
  bool setParam<T>(Comparable key, T value) {
    // Anchor module does not need to set param scheme.
    if (this == anchor) {
      _params[key] = value;
      return true;
    }

    if (!_paramSchemes.keys.contains(key) ||
        _paramSchemes[key] != value.runtimeType) {
      return false;
    }
    _params[key] = value;
    return true;
  }

  /// Remove param by `key` & `T`, if exists, return the `value`.
  ///
  /// Throw `ThrioException` if `T` is not matched param scheme.
  ///
  T removeParam<T>(Comparable key) {
    // Anchor module does not need to get param scheme.
    if (this == anchor) {
      return _params.remove(key) as T; // ignore: avoid_as
    }
    if (T != dynamic &&
        _paramSchemes.keys.contains(key) &&
        _paramSchemes[key] != T) {
      throw ThrioException(
        '$T does not match the param scheme type: ${_paramSchemes[key]}',
      );
    }
    return _params.remove(key) as T; // ignore: avoid_as
  }

  /// A function for register a param scheme.
  ///
  @protected
  void onParamSchemeRegister(ModuleContext moduleContext) {}

  /// Register a param scheme for the module.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  @protected
  VoidCallback registerParamScheme<T>(String key) {
    if (_paramSchemes.keys.contains(key)) {
      return null;
    }
    return _paramSchemes.registry(key, T);
  }
}
