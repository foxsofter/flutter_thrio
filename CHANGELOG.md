## 0.0.1

- TODO: Describe initial release.

## 0.1.0

- fix: Android push always return index.
- fix: remove signle_top for Android native Activity.

## 0.1.1

- fix: hot restart 导致 pop 失效

## 0.1.2

- fix: iOS 下面 Dart 页面通知的 bug

## 0.1.3

- fix: Android demo 原生页面和 Flutter 页面转场动画不一致
- fix: iOS hidesNavigationBar 设置后原生页面一直生效的 bug

## 0.1.4

- feat: remove reuse of isInitialRoute
- fix: Android setSystemUIOverlayStyle 不生效
- doc: 添加日志开关文档
- feat: add iOS log switch
- doc: add push and notify demo
- fix: pop with parameters does not cover all cases
- fix: Repeatedly add NavigatorObserverManager
- fix: crash at UINavigationController.setViewControllers
- feat: add dart navigator log disable
- fix: 优化导航栏切换效果

## 0.1.5

- fix: url 带 . 时引起的冲突，issue #27

## 0.1.6

- fix: popResult 失败

## 0.1.7

- fix: Android didn't notify after popTo
- fix: Android didn't call onPopResult from native pop to flutter

## 0.1.8

- fix: ios memory leak

## 0.2.0

- feat: add flutter custom transition builder api.

## 0.2.1

- fix: crash case on f->n->f .

## 0.2.2

- fix: iOS index not sync when back gesture.

## 0.3.0

- fix: issue 44, android keyboard not showing up

## 0.4.0

- refact: 重构 Android 源码
- feat: 增加通知所有对应 url 实例的能力
- fix: 修复部分已知 bug

## 0.4.1

- fix: #57，兼容 UIImagePickerControllerDelegate

## 0.4.2

- fix: UINavigationController.setDelete nil

## 0.4.3

- fix: ThrioStatefulWidget.tryStateOf should not throw an exception.
- feat: add extension methods for get `RouteSettings` properties.

## 0.4.4

- fix: issue 63
