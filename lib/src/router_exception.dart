// Copyright (c) 2019/12/03, 10:43:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

class RouterException extends Exception {
  factory RouterException([String message]) => _RouterException(message);
}

class _RouterException implements RouterException {
  const _RouterException(this.message);

  final String message;

  @override
  String toString() => 'RouterException: ${message ?? ''}';
}
