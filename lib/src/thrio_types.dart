// Copyright (c) 2019/12/11, 10:42:59 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

import 'package:flutter/widgets.dart';

/// Signature for a function that creates a page widget.
///
typedef PageBuilder = Widget Function(
  String url, {
  int index,
  Map<String, dynamic> params,
});

/// States that a thrio page can be in.
///
enum PageLifecycle {
  inited,
  willAppear,
  appeared,
  willDisappear,
  disappeared,
  destroyed,
  background,
  foreground,
}
