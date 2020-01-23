// Copyright (c) 2019/12/11, 10:42:59 PM The Hellobike. All rights reserved.
// Created by WeiZhongdan, weizhongdan06291@hellobike.com.

/// States that a thrio page can be in.
///
enum PageLifecycle {
  inited,
  willAppear,
  appeared,
  willDisappear,
  disappeared,
  destroyed,
}
