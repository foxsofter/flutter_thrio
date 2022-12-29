// Copyright (c) 2022 foxsofter.
//

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_thrio/flutter_thrio.dart';

/// 发送邮箱验证码
///
FutureOr<bool?> onSendEmailCode(
  final ModuleContext moduleContext,
  final String url,
  final String action,
  final Map<String, List<String>> queryParams, {
  final BuildContext? context,
  required final String email,
  final int? currentFrom,
  final String? coin,
  final String? amount,
  final String? address,
  final String? tag,
}) async {
  debugPrint('onSendEmail:$email');
  return null;
}
