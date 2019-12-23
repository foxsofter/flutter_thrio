// Copyright (c) 2019/12/03, 10:43:58 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

class ThrioException extends Exception {
  factory ThrioException([String message]) => _ThrioException(message);
}

class _ThrioException implements ThrioException {
  const _ThrioException(this.message);

  final String message;

  @override
  String toString() => 'ThrioException: ${message ?? ''}';
}
