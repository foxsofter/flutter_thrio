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
  ThrioModule get module => moduleOf[this];

  /// Get param `value` of `key`.
  ///
  /// If not exist, get from parent module's `ModuleContext`.
  ///
  T get<T>(String key) {
    if (module is ModuleParamScheme) {
      final value = (module as ModuleParamScheme).getParam<T>(key);
      if (value != null) {
        return value;
      }
    }
    return module.parent?._moduleContext?.get<T>(key);
  }

  /// Set param `value` with `key`.
  ///
  /// Return `false` if param scheme is not registered.
  ///
  bool set<T>(String key, T value) {
    if (module is ModuleParamScheme) {
      if ((module as ModuleParamScheme).setParam<T>(key, value)) {
        return true;
      }
    }
    return module.parent?._moduleContext?.set<T>(key, value) ?? false;
  }

  @override
  String toString() => 'Context of module ${module.key}';
}
