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

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../exception/thrio_exception.dart';
import '../registry/registry_map.dart';
import 'module_anchor.dart';
import 'thrio_module.dart';

mixin ModuleParamScheme on ThrioModule {
  /// Param schemes registered in the current Module
  ///
  final _paramSchemes = RegistryMap<Comparable<dynamic>, Type>();

  @protected
  bool hasParamScheme<T>(Comparable<dynamic> key) {
    if (_paramSchemes.keys.contains(key)) {
      if (T == dynamic || T == Object) {
        return true;
      }
      return _paramSchemes[key] == T;
    }
    return false;
  }

  @protected
  final paramStreamCtrls =
      <Comparable<dynamic>, Set<StreamController<dynamic>>>{};

  /// Subscribe to a series of param by `key`.
  ///
  @protected
  Stream<T?>? onParam<T>(Comparable<dynamic> key, {T? initialValue}) {
    paramStreamCtrls[key] ??= <StreamController<dynamic>>{};
    final sc = StreamController<T?>();
    sc
      ..onListen = () {
        paramStreamCtrls[key]?.add(sc);
        // sink lastest value.
        final value = getParam<T>(key);
        if (value != null) {
          sc.add(value);
        } else if (initialValue != null) {
          sc.add(initialValue);
        }
      }
      ..onCancel = () {
        paramStreamCtrls[key]?.remove(sc);
      };
    return sc.stream;
  }

  final _params = <Comparable<dynamic>, dynamic>{};

  /// Gets param by `key` & `T`.
  ///
  /// Throw `ThrioException` if `T` is not matched param scheme.
  ///
  @protected
  T? getParam<T>(Comparable<dynamic> key) {
    // Anchor module does not need to get param scheme.
    if (this == anchor) {
      return _params[key] as T?;
    }
    if (!_paramSchemes.keys.contains(key)) {
      return null;
    }
    final value = _params[key];
    if (value == null) {
      return null;
    }
    if (T != dynamic && T != Object && value is! T) {
      throw ThrioException(
          '$T does not match the param scheme type: ${value.runtimeType}');
    }
    return value as T?;
  }

  /// Sets param with `key` & `value`.
  ///
  /// Return `false` if param scheme is not registered.
  ///
  @protected
  bool setParam<T>(Comparable<dynamic> key, T value) {
    // Anchor module does not need to set param scheme.
    if (this == anchor) {
      final oldValue = _params[key];
      if (oldValue != null && oldValue.runtimeType != value.runtimeType) {
        return false;
      }
      _setParam(key, value);
      return true;
    }
    if (!_paramSchemes.keys.contains(key)) {
      return false;
    }
    final schemeType = _paramSchemes[key];
    if (schemeType == dynamic || schemeType == Object) {
      final oldValue = _params[key];
      if (oldValue != null && oldValue.runtimeType != value.runtimeType) {
        return false;
      }
    } else {
      if (schemeType.toString() != value.runtimeType.toString()) {
        return false;
      }
    }
    _setParam(key, value);
    return true;
  }

  void _setParam(Comparable<dynamic> key, dynamic value) {
    if (_params[key] != value) {
      _params[key] = value;
      final scs = paramStreamCtrls[key];
      if (scs == null || scs.isEmpty) {
        return;
      }
      for (final sc in scs) {
        if (sc.hasListener && !sc.isPaused && !sc.isClosed) {
          sc.add(value);
        }
      }
    }
  }

  /// Remove param by `key` & `T`, if exists, return the `value`.
  ///
  /// Throw `ThrioException` if `T` is not matched param scheme.
  ///
  T? removeParam<T>(Comparable<dynamic> key) {
    // Anchor module does not need to get param scheme.
    if (this == anchor) {
      return _params.remove(key) as T?;
    }
    if (T != dynamic &&
        T != Object &&
        _paramSchemes.keys.contains(key) &&
        _paramSchemes[key] != T) {
      throw ThrioException(
          '$T does not match the param scheme type: ${_paramSchemes[key]}');
    }
    final param = _params.remove(key) as T?;
    if (param != null) {
      _setParam(key, param);
    }
    return param;
  }

  /// A function for register a param scheme.
  ///
  @protected
  void onParamSchemeRegister(ModuleContext moduleContext) {}

  /// Register a param scheme for the module.
  ///
  /// `T` can be optional.
  ///
  /// Unregistry by calling the return value `VoidCallback`.
  ///
  @protected
  VoidCallback registerParamScheme<T>(Comparable<dynamic> key) {
    if (_paramSchemes.keys.contains(key)) {
      throw ThrioException(
          '$T is already registered for key ${_paramSchemes[key]}');
    }
    final callback = _paramSchemes.registry(key, T);
    return () {
      callback();
      final scs = paramStreamCtrls.remove(key);
      if (scs != null && scs.isNotEmpty) {
        for (final sc in scs) {
          sc.close();
        }
      }
    };
  }
}
