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

// ignore_for_file: invalid_use_of_protected_member, avoid_as

part of 'thrio_module.dart';

class ModuleContext {
  ModuleContext({this.entrypoint = 'main'});

  /// Entrypoint of current app.
  ///
  final String entrypoint;

  /// Module of module context.
  ///
  ThrioModule get module => moduleOf[this]!;

  /// Get param `value` of `key`.
  ///
  /// If not exist, get from parent module's `ModuleContext`.
  ///
  T? get<T>(final String key) {
    if (module is ModuleParamScheme) {
      final value = (module as ModuleParamScheme).getParam<T>(key);
      if (value != null) {
        return value;
      }
    }
    return module.parent?._moduleContext.get<T>(key);
  }

  /// Set param `value` with `key`.
  ///
  /// Return `false` if param scheme is not registered.
  ///
  bool set<T>(final String key, final T value) {
    if (module is ModuleParamScheme) {
      if ((module as ModuleParamScheme).setParam<T>(key, value)) {
        return true;
      }
    }
    // Anchor module caches the data of the framework
    return module.parent != anchor &&
        module.parent != null &&
        (module.parent?._moduleContext.set<T>(key, value) ?? false);
  }

  /// Remove param with `key`.
  ///
  /// Return `value` if param not exists.
  ///
  T? remove<T>(final String key) {
    if (module is ModuleParamScheme) {
      final value = (module as ModuleParamScheme).removeParam<T>(key);
      if (value != null) {
        return value;
      }
    }
    // Anchor module caches the data of the framework
    return module.parent == anchor || module.parent == null
        ? null
        : module.parent?._moduleContext.remove<T>(key);
  }

  /// Subscribe to a series of param by `key`.
  ///
  Stream<T>? on<T>(final String key, {final T? initialValue}) {
    if (module == anchor) {
      return anchor.onParam(key, initialValue: initialValue);
    }

    if (module is ModuleParamScheme) {
      final paramModule = module as ModuleParamScheme;
      if (paramModule.hasParamScheme<T>(key)) {
        return paramModule.onParam(key, initialValue: initialValue);
      }
    }

    return module.parent?._moduleContext.on(key, initialValue: initialValue);
  }

  @override
  String toString() => 'Context of module ${module.key}';
}
