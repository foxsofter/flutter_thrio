// The MIT License (MIT)
//
// Copyright (c) 2022 foxsofter
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

import 'package:flutter/material.dart';

import '../exception/thrio_exception.dart';

@immutable
class NavigatorUrlTemplate {
  NavigatorUrlTemplate({required this.template}) {
    var tem = template;
    final paramsStr = RegExp(r'\{(.*?)\}').stringMatch(tem);
    if (paramsStr != null) {
      tem = tem.replaceAll(paramsStr, '');
    }
    final parts = tem.split('://');
    if (parts.length > 2) {
      throw ThrioException('inivalid template: $template');
    } else if (parts.length == 2) {
      scheme = parts[0].toLowerCase();
      host = parts[1].split('/')[0];
      path = parts[1].replaceFirst(host, '');
    } else {
      scheme = '';
      host = '';
      path = tem;
    }
    if (paramsStr != null) {
      final paramsKeys = paramsStr
          .replaceAll(' ', '')
          .replaceAll('{', '')
          .replaceAll('}', '')
          .split(',');
      requiredParamKeys.addAll(paramsKeys
          .where((it) => it.isNotEmpty && !it.endsWith('?'))
          .map((it) => it.replaceAll('?', '')));
    }
  }

  final String template;

  late final String scheme;
  late final String host;
  late final String path;
  final List<String> requiredParamKeys = <String>[];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is NavigatorUrlTemplate && template == other.template;
  }

  bool match(Uri uri) {
    // url 允许通过传入模板来表明使用者已经正常传入参数
    var uriPath = Uri.decodeFull(uri.path);
    var uriParamsKeys = uri.queryParametersAll.keys;
    if (uriPath.contains('{')) {
      uriParamsKeys = uriPath
          .split('{')[1]
          .replaceAll('}', '')
          .replaceAll('=', '?')
          .split(',');
      uriPath = uriPath.split('{')[0];
    }
    if (scheme == uri.scheme &&
        ((host.contains('*') &&
                RegExp(host.replaceFirst('*', '.*')).hasMatch(uri.host)) ||
            host == uri.host) &&
        (path.isEmpty || path == uriPath)) {
      if (requiredParamKeys.isEmpty) {
        return true;
      }
      if (!requiredParamKeys.any((k) => !uriParamsKeys.contains(k))) {
        return true;
      }
    }
    return false;
  }

  @override
  int get hashCode => template.hashCode;

  @override
  String toString() => template;
}
