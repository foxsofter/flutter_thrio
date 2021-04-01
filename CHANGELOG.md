## 0.0.1

* TODO: Describe initial release.

## 0.1.0

* fix: Android push always return index.
* fix: remove signle_top for Android native Activity.

## 0.1.1

* fix: hot restart 导致 pop 失效

## 0.1.2

* fix: iOS 下面 Dart 页面通知的 bug

## 0.1.3

* fix: Android demo 原生页面和 Flutter 页面转场动画不一致
* fix: iOS hidesNavigationBar 设置后原生页面一直生效的 bug

## 0.1.4

* feat: remove reuse of isInitialRoute
* fix: Android setSystemUIOverlayStyle 不生效
* doc: 添加日志开关文档
* feat: add iOS log switch
* doc: add push and notify demo
* fix: pop with parameters does not cover all cases
* fix: Repeatedly add NavigatorObserverManager
* fix: crash at UINavigationController.setViewControllers
* feat: add dart navigator log disable
* fix: 优化导航栏切换效果

## 0.1.5

* fix: url 带 . 时引起的冲突，issue #27

## 0.1.6

* fix: popResult 失败

## 0.1.7

* fix: Android didn't notify after popTo
* fix: Android didn't call onPopResult from native pop to flutter

## 0.1.8

* fix: ios memory leak

## 0.2.0

* feat: add flutter custom transition builder api.

## 0.2.1

* fix: crash case on f->n->f .

## 0.2.2

* fix: iOS index not sync when back gesture.

## 0.3.0

* fix: issue 44, android keyboard not showing up

## 0.4.0

* refact: 重构 Android 源码
* feat: 增加通知所有对应 url 实例的能力
* fix: 修复部分已知 bug

## 0.4.1

* fix: #57，兼容 UIImagePickerControllerDelegate

## 0.4.2

* fix: UINavigationController.setDelete nil

## 0.4.3

* fix: ThrioStatefulWidget.tryStateOf should not throw an exception.
* feat: add extension methods for get `RouteSettings` properties.

## 0.4.4

* fix: issue 63

## 0.5.0

* feat: add android page & route lifecycle
* feat: now it can run under Flutter SDK 1.20.x

## 0.5.1

* feat: add android log disabled
* fix: onRemove typepo
* fix: flutter to flutter notify not working

## 1.0.0

* feat: support multiple UINavigationController for iOS
* feat: support multiple flutter engine
* feat: support 1.22.x flutter SDK
* feat: refactor page observer
* feat: add more linter rules
* fix: #106 #107 #108 #109

## 1.0.1

* feat: support root FlutterViewController and ThrioActivity
* feat: add interface for builder and navigatorObservers
* fix: #118

## 1.1.0

* feat: support for passing complex types between flutter pages
* feat: support notify all page

## 1.2.0

* fix: issue #123，解决`1.1.0`版本中存在的 pop native 到原生 poppedResult 不调用的问题
* feat: 支持在所有页面间传递Json对象，为相关 API 添加泛型支持
* feat: Flutter端添加 `lastRoute`,          `allRoutes` 两个新的 API
* feat: 删除 `lastIndex`，`allIndexes` 这两个 API

## 1.2.1

* fix: 去掉 Android Flutter 页面打开时的黑屏

## 1.3.0

* feat: 更好的支持 Android root FlutterActivity

## 1.3.1

* fix: poppedResult return pushed params 

## 1.3.2

* fix: remove moduleContext from NavigatorPageBuilder

## 1.3.3

* fix: issue #135, 原生页面第二次跳转 Flutter 页面失败

## 1.3.4

* fix: issue #138，serializerParams 失败

## 1.3.5

* fix: pageChannel and routeChannel not match the readwrite property

## 1.3.6

* fix: json object not support on didXXX

## 1.3.7

* fix: issue #140 remove rootViewController 可能失效的bug

## 1.4.0

* feat: Module 与 `url` 必须一一对应
* feat: `PageObserver` 和 `RouteObserver` 只能收到本 Module 和 子Module 下面的页面的周期
* feat: `JsonSerializer` 和  `JsonDeserializer` 会优先查找对应 url 的 叶Module，并依次往 父 Module 查找
* feat: `PageBuilder` 注册不在需要传入 `url`，只有在叶Module设置才生效
* feat: `TransitionsBuilder` 注册不在需要传入正则字符串，可以在任意 Module 设置，本Module 和 子Module 下的页面都会生效，优先级是 子Module 的 `TransitionsBuilder` 高
* feat: 增加 `ProtobufSerializer` 和 `ProtobufDeserializer` ，会优先查找对应 url 的 叶Module，并依次往 父 Module 查找，但暂时不会在 页面传参中生效
* fix: 修复已知的bug，iOS下设置 willPop = NO 后 poppedResult 依然调用的bug，iOS下页面生命周期未传给Flutter的bug

## 1.4.1

* fix: page observer widget not working
* feat: 拆解 ModuleContext

## 1.4.2

* feat: `ModuleContext` 提供 `get` 和 `set` 参数的接口
* feat: `ModuleContext` 提供的参数的作用范围由 `Module` 决定，一个 `Module` 下面的参数可以由任何一个子 `Module` 的 `ModuleContext` `get` 和 `set`
* fix: issue #140 remove rootViewController 可能失效的bug

## 1.4.3

* fix: issue #141，修复Android下首页为FlutterActivity引起光标不可见

## 1.4.4

* feat: update demo, add hot restart for ios

## 1.4.5

* feat: url automatically matches home

## 1.4.6

* feat: 允许 页 Module 反向忽略掉 父 Module 设置的转场动画 

## 1.5.0

* feat: 增加 Flutter 侧对 Navigator 的 push 和 pop 的支持

## 1.5.1

* feat: 增加 Flutter 侧对 Navigator 的 canPop 的支持，可用于隐藏返回箭头

## 1.5.2

* feat: 增加对Flutter页面强制横屏的支持
* fix: Flutter页面生命周期在Flutter为首页的情况下存在的bug

## 1.6.0

* feat: supports `Module` auto loading and unloading

## 1.6.1

* fix: Android `NavigationController.context` 改成弱引用

## 1.6.2

* fix: Android crash at context.get()!!

## 1.7.0

* feat: 支持单引擎下 Flutter 页面之间直接传递复杂类型，无需设置序列化器和反序列化器
* fix: `ModuleContext` 增加 `remove` 方法
* fix: Android 下在 Acitivity 释放掉引起的崩溃

## 1.7.1

* feat: add canPopResult

## 1.7.2

* fix: Android pop一个原生页面后无法再 push Flutter 页面

## 1.7.3

* fix: change `onModuleLoading` to async method.

## 1.7.4

* fix: 修复部分Android机型可能出现的无法获取当前 Activity 的bug，导致无法 push 页面

## 1.7.5

* fix: 可能出现的 `NavigatorPageRoute` as 失败

## 1.7.6

* fix: iOS `remove` 时如果 `url` 拼写错误导致 result 不调用

## 1.7.7

* fix: 修复 issue #152

## 1.7.8

* feat: 添加 `isContainsInnerRoute`
* feat: 当 route 为 `PopupRoute` 时，不触发 `didAppear`
* fix: Android 下出现的异常

## 1.7.9

* fix: 1.7.7 和 1.7.8 出现的 `pop` 失败

## 1.7.10

* fix: support TransitionBuilder

## 1.7.11

* fix: Activity 被系统杀掉可能引起的无法 `pop` 的问题

## 1.8.0

* feat: 添加 `iOS` 和 `Android` 的 `ModuleContext`，并默认传递给 `Flutter`
* feat: 完善 `shouldCanPop`，支持混合栈用于判断是否显示箭头
* fix: 修复 `ThrioActivity` 作为 lanuch Activity 时可能导致出现加载页的bug
* feat: `ModuleContext` 支持 `Stream` 接口

## 1.8.1

* feat: 增加 `lastFlutterRoute` 和 `allFlutterRoutes` 两个 接口
* fix: `lastRoute` 返回空不是 `null`

## 1.8.2

* feat: 移除 kotlin-android-extensions
* feat: 适配 Flutter 2.x.x 版本

## 1.8.3

* fix: 回滚对 Flutter 2.x.x 的适配
* fix: 修复一些资源释放问题
* fix: 修复Dart异常

## 1.8.4

* fix: 优化 dart 代码
* fix: 修复部分使用场景下的 bug

## 2.0.0

* feat: 适配 Flutter 2.x.x

## 2.0.0-nullsafety

* feat: support null safety
* feat: support flutter 2.0
* fix: bugs
  
## 2.0.1

* fix: moduleContext.on 无法收到原生的状态
  
## 2.0.1-nullsafety

* fix: moduleContext.on 无法收到原生的状态