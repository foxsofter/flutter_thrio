## 3.14.7

- feat: add objc swizzle method
- fix: load dispatch once


## 3.14.6

- refactor: android engine startup flow
- fix: occasional non-popable issues
- fix: _delegate._current not init exception
- fix: __NSCFBoolean compare: nil argument
- fix: result nil crash
- feat: async task queue timeout

## 3.14.5

- fix: https://developer.apple.com/forums/thread/714608
- chore: add runOnce for restart button

## 3.14.4

- fix: engine property crash
- fix: comment loading in replace
- fix: can not pop caused by the page stack mismatch

## 3.14.3

- feat: add NavigatorWillPop and NavigatorWillPopMixin
  
## 3.14.2

- fix: async task queue not working expected when task throw exception

## 3.14.1

- fix: ios isEqualToNumber nil crash
- fix: android ArrayIndexOutOfBoundsException
- feat: route custom handler support url queryParameter not decode
- feat: navigator push auto parse query parameters to params when it is null or map

## 3.14.0

- fix: android back click not working
- fix: NavigatorPageLifecycleMixin not working on const widget
- fix: NavigatorPageLifecycleMixin first init didAppear 
- fix: NavigatorPageLifecycleMixin still working when widget not correct dispose
- fix: observers concurrent modification during iteration
- feat: support didPopRoute in page
- feat: add NavigatorWillPopMixin
- fix: android allRoutes with url return empty collection
- fix: http uri fragment missing

## 3.13.0

- rm loading/unloading and fix ios push duplicate
- feat: auto restart
- feat: support android hot restart
- fix: maybePop can not pop in some case
- refactor: rm /home can be optional logic 
- feat: handle didUpdateWidget for NavigatorRoutePush state 
- feat: handle didChangeDependencies for NavigatorPageLifecycleMixin
- feat: handle didUpdateWidget for  NavigatorPageNotify 
- feat: android support fragment
- fix: routeSettings for NavigatorPageView not refresh
- feat: make page view lifecycle work for NavigatorPageObserver 
- feat: support root page WillPopScope
- fix: kline land not trigger WillPopScope

## 3.12.5

- fix: ios disappear not trigger

## 3.12.4

- refactor: lastFlutterRoute and allFlutterRoutes return type to NavigatorRoute
- refactor: isContainsInnerRoute to isDialogAbove

## 3.12.3

- fix: NavigatorPageLifecycleMixin anchors exists duplicate RouteSettings

## 3.12.2

- feat: NavigatorPageObserver will call by fileter by settings.name
- feat: add keepIndex for NavigatorTabBarView

## 3.12.1

- fix: Call popResult after the route is removeed, popped, replaced
- fix: can not pop

## 3.12.0

- fix: 进入后台或者前台重复触发的问题
- fix: page maybePop call popResult
- feat: rm BuildContext from build
- feat: add keepIndex for NavigatorPageView
- fix: PageController.lenght is 0
- fix: naviagtor page view lifecycle
- fix: url template parse error
- feat: NavigatorPageView onPageChanged add index
- fix: lastWhereOrNull predicate item reversed

## 3.11.0

- refactor: 重构页面生命周期的实现
- fix: 修复一些累积 bug

## 3.10.8

- fix: revert lastWhereOrNull not reversed

## 3.10.7

- fix: lastWhereOrNull not reversed
- feat: add alwaysTakeEffect for NavigatorRoutePush

## 3.10.6

- fix: FlutterActivity 在混合栈场景下可能出现的页面生命周期混乱

## 3.10.5

- feat: NavigatorPage.moduleContextOf return rootModuleContext if none

## 3.10.4

- fix: 修复 poppedResult 返回值都为 null 的问题

## 3.10.3

- fix: 调整 NavigatorPageView 触发 disappear 和 appear 的顺序

## 3.10.2

- fix: 侧滑返回不触发 poppedResult

## 3.10.1

- fix: NavigatorRouteSettings settingsWith index 参数改为可空

## 3.10.0

- refactor: NavigatorPageLifecycle, NavigatorPageLifecycleMixin, NavigatorPageView

## 3.9.12

- fix: 修复 NavigatorPageLifecycle 在 NavigatorPageView 情形下首次不触发的问题

## 3.9.11

- feat: page lifecycle observer default to be NavigatorPage.urlOf

## 3.9.10

- fix: page life cycle 错误

## 3.9.9

- fix: route-action miss match

## 3.9.8

- feat: add getListParam, getMapParam

## 3.9.7

- fix: canPop should not call willPop

## 3.9.6

- feat: feat: set default value for context on

## 3.9.5

- feat: public method [NavigatorPage.of]

## 3.9.4

- feat: add [NavigatorPage.moduleOf],[NavigatorPage.paramsOf],[NavigatorPage.urlOf],[NavigatorPage.indexOf].
- refactor: RouteSettings.url to not nullable property.

## 3.9.3

- feat: add method [NavigatorPage.of]

## 3.9.2

- feat: route-custom-handler support domain name wildcard

## 3.9.1

- feat: route-action 支持通过传入模板来表明参数已正确传入

## 3.9.0

- feat: add NavigatorRouteAction and remove uri.dart
- feat: support route-action code generate

## 3.8.8

- fix: remove callback invalid

## 3.8.7

- fix: pushReplace not working with custom route handler

## 3.8.6

- fix: url template match only path

## 3.8.5

- fix: url template requires a path match

## 3.8.4

- feat: android onBackPressed = maybePop

## 3.8.3

- fix: 修复 NavigatorRoutePush 在首页时进入后台再回来的偶发不生效的问题

## 3.8.2

- feat: 支持多个根部 module 为空的 key 的情况

## 3.8.1

- feat: tabview 支持 child 定制

## 3.8.0

- feat: add pushAndRemoveToFirst, pushAndRemoveUntil, pushAndRemoveUntilFirst
- feat: add notifyAll, notifyFrist, notifyFirstWher, notifyWhere, notifyLastWhere,
- feat: add removeFirst, removeAll
- feat: add replaceFirst

## 3.7.2

- feat: add popUntil, popUntilFirst
- feat: add removeBelowUntil, removeBelowUntilFirst

## 3.7.1

- feat: add popToFirst

## 3.7.0

- feat: add pushAndRemoveTo
- refactor: push return type nullable
- fix: NavigatorRoutePush not working when enter foreground

## 3.6.2

- feat: url template support only scheme

## 3.6.1

- fix: 修复 NavigatorPageView 互相嵌套内部的 didAppear 不触发的问题

## 3.6.0

- feat: NavigatorRoutePush handle with multiple url

## 3.5.3

- fix: 修复 NavigatorRoutePush 在首页时不生效的问题

## 3.5.2

- feat: 优化 Android 引擎释放的逻辑
- fix: 修复 iOS 在混合栈的场景只有一个页面时无法 pop 的问题

## 3.5.1

- feat: url template support optional params

## 3.5.0

- feat: add popToRoot
- feat: add maybePop
- feat: add pushReplace
- refactor: rm replaceOnly

## 3.4.1

- refactor: Reduce the parameters of ModuleRouteCustomHandler

## 3.4.0

- feat: custom route handle with params
- refactor: rename shouldCanPop to showPopAwareWidget

## 0.1.1

- fix: hot restart 导致 pop 失效

## 0.1.0

## 3.2.0

- feat: The return value of the push method is changed to be consistent with Flutter's push method

## 3.1.5

- feat: flutter support canPop
- refactor: NavigatorTabBarView and NavigatorPageView

## 3.1.4

- feat: NavigatorTabBarView, NavigatorPageView support nesting

## 3.1.3

## 3.1.2

- feat: export thrio_dynamic

## 3.1.1

- feat: add thrio_dynamic extension method

## 3.1.0

- feat: NavigatorRoutePush support given url
- feat: ios didAppear and didDisappear call when from background and enter foreground
- feat: add NavigatorTabBarView and NavigatorPageView
- feat: add NavigatorPageLifecycleMixin
- feat: onModuleInit change to async method
- feat: add build method for ThrioNavigator
- feat: add NavigatorDialogRoute

## 3.0.2

- feat: Support custom route builder.

## 3.0.1

- feat: Adjust Module init order to make it predictable

## 3.0.0+1

- feat: support flutter3

## 2.0.11

- feat: code format for line length 100

## 2.0.9

- fix: viewPaddingTop -> viewInsetTop

## 2.0.7

- fix: NSStringFromClass 判断类型的错误
- fix: ModuleContext.on 方法订阅原生状态失败

## 2.0.3-nullsafety

- fix: 因为 nullsafety 版本被覆盖，后续奇数版本支持，偶数版本不支持 nullsafety

## 2.0.2-nullsafety

- fix: 原生页面 pop 某些场景下可能将 Flutter 页面也 pop

## 2.0.2

- fix: 原生页面 pop 某些场景下可能将 Flutter 页面也 pop

## 2.0.1-nullsafety

- fix: moduleContext.on 无法收到原生的状态

## 2.0.1

- fix: moduleContext.on 无法收到原生的状态

## 2.0.0-nullsafety

- feat: support null safety
- feat: support flutter 2.0
- fix: bugs

## 2.0.0

- feat: 适配 Flutter 2.x.x

## 1.8.4

- fix: 优化 dart 代码
- fix: 修复部分使用场景下的 bug

## 1.8.3

- fix: 回滚对 Flutter 2.x.x 的适配
- fix: 修复一些资源释放问题
- fix: 修复 Dart 异常

## 1.8.2

- feat: 移除 kotlin-android-extensions
- feat: 适配 Flutter 2.x.x 版本

## 1.8.1

- feat: 增加 `lastFlutterRoute` 和 `allFlutterRoutes` 两个 接口
- fix: `lastRoute` 返回空不是 `null`

## 1.8.0

- feat: 添加 `iOS` 和 `Android` 的 `ModuleContext`，并默认传递给 `Flutter`
- feat: 完善 `shouldCanPop`，支持混合栈用于判断是否显示箭头
- fix: 修复 `ThrioActivity` 作为 lanuch Activity 时可能导致出现加载页的 bug
- feat: `ModuleContext` 支持 `Stream` 接口

## 1.7.11

- fix: Activity 被系统杀掉可能引起的无法 `pop` 的问题

## 1.7.10

- fix: support TransitionBuilder

## 1.7.9

- fix: 1.7.7 和 1.7.8 出现的 `pop` 失败

## 1.7.8

- feat: 添加 `isContainsInnerRoute`
- feat: 当 route 为 `PopupRoute` 时，不触发 `didAppear`
- fix: Android 下出现的异常

## 1.7.7

- fix: 修复 issue #152

## 1.7.6

- fix: iOS `remove` 时如果 `url` 拼写错误导致 result 不调用

## 1.7.5

- fix: 可能出现的 `NavigatorPageRoute` as 失败

## 1.7.4

- fix: 修复部分 Android 机型可能出现的无法获取当前 Activity 的 bug，导致无法 push 页面

## 1.7.3

- fix: change `onModuleLoading` to async method.

## 1.7.2

- fix: Android pop 一个原生页面后无法再 push Flutter 页面

## 1.7.1

- feat: add canPopResult

## 1.7.0

- feat: 支持单引擎下 Flutter 页面之间直接传递复杂类型，无需设置序列化器和反序列化器
- fix: `ModuleContext` 增加 `remove` 方法
- fix: Android 下在 Acitivity 释放掉引起的崩溃

## 1.6.2

- fix: Android crash at context.get()!!

## 1.6.1

- fix: Android `NavigationController.context` 改成弱引用

## 1.6.0

- feat: supports `Module` auto loading and unloading

## 1.5.2

- feat: 增加对 Flutter 页面强制横屏的支持
- fix: Flutter 页面生命周期在 Flutter 为首页的情况下存在的 bug

## 1.5.1

- feat: 增加 Flutter 侧对 Navigator 的 canPop 的支持，可用于隐藏返回箭头

## 1.5.0

- feat: 增加 Flutter 侧对 Navigator 的 push 和 pop 的支持

## 1.4.6

- feat: 允许 页 Module 反向忽略掉 父 Module 设置的转场动画

## 1.4.5

- feat: url automatically matches home

## 1.4.4

- feat: update demo, add hot restart for ios

## 1.4.3

- fix: issue #141，修复 Android 下首页为 FlutterActivity 引起光标不可见

## 1.4.2

- feat: `ModuleContext` 提供 `get` 和 `set` 参数的接口
- feat: `ModuleContext` 提供的参数的作用范围由 `Module` 决定，一个 `Module` 下面的参数可以由任何一个子 `Module` 的 `ModuleContext` `get` 和 `set`
- fix: issue #140 remove rootViewController 可能失效的 bug

## 1.4.1

- fix: page observer widget not working
- feat: 拆解 ModuleContext

## 1.4.0

- feat: Module 与 `url` 必须一一对应
- feat: `PageObserver` 和 `RouteObserver` 只能收到本 Module 和 子 Module 下面的页面的周期
- feat: `JsonSerializer` 和 `JsonDeserializer` 会优先查找对应 url 的 叶 Module，并依次往 父 Module 查找
- feat: `PageBuilder` 注册不在需要传入 `url`，只有在叶 Module 设置才生效
- feat: `TransitionsBuilder` 注册不在需要传入正则字符串，可以在任意 Module 设置，本 Module 和 子 Module 下的页面都会生效，优先级是 子 Module 的 `TransitionsBuilder` 高
- feat: 增加 `ProtobufSerializer` 和 `ProtobufDeserializer` ，会优先查找对应 url 的 叶 Module，并依次往 父 Module 查找，但暂时不会在 页面传参中生效
- fix: 修复已知的 bug，iOS 下设置 willPop = NO 后 poppedResult 依然调用的 bug，iOS 下页面生命周期未传给 Flutter 的 bug

## 1.3.7

- fix: issue #140 remove rootViewController 可能失效的 bug

## 1.3.6

- fix: json object not support on didXXX

## 1.3.5

- fix: pageChannel and routeChannel not match the readwrite property

## 1.3.4

- fix: issue #138，serializerParams 失败

## 1.3.3

- fix: issue #135, 原生页面第二次跳转 Flutter 页面失败

## 1.3.2

- fix: remove moduleContext from NavigatorPageBuilder

## 1.3.1

- fix: poppedResult return pushed params

## 1.3.0

- feat: 更好的支持 Android root FlutterActivity

## 1.2.1

- fix: 去掉 Android Flutter 页面打开时的黑屏

## 1.2.0

- fix: issue #123，解决`1.1.0`版本中存在的 pop native 到原生 poppedResult 不调用的问题
- feat: 支持在所有页面间传递 Json 对象，为相关 API 添加泛型支持
- feat: Flutter 端添加 `lastRoute`, `allRoutes` 两个新的 API
- feat: 删除 `lastIndex`，`allIndexes` 这两个 API

## 1.1.0

- feat: support for passing complex types between flutter pages
- feat: support notify all page

## 1.0.1

- feat: support root FlutterViewController and ThrioActivity
- feat: add interface for builder and navigatorObservers
- fix: #118

## 1.0.0

- feat: support multiple UINavigationController for iOS
- feat: support multiple flutter engine
- feat: support 1.22.x flutter SDK
- feat: refactor page observer
- feat: add more linter rules
- fix: #106 #107 #108 #109

## 0.5.1

- feat: add android log disabled
- fix: onRemove typepo
- fix: flutter to flutter notify not working

## 0.5.0

- feat: add android page & route lifecycle
- feat: now it can run under Flutter SDK 1.20.x

## 0.4.4

- fix: issue 63

## 0.4.3

- fix: ThrioStatefulWidget.tryStateOf should not throw an exception.
- feat: add extension methods for get `RouteSettings` properties.

## 0.4.2

- fix: UINavigationController.setDelete nil

## 0.4.1

- fix: #57，兼容 UIImagePickerControllerDelegate

## 0.4.0

- refact: 重构 Android 源码
- feat: 增加通知所有对应 url 实例的能力
- fix: 修复部分已知 bug

## 0.3.0

- fix: issue 44, android keyboard not showing up

## 0.2.2

- fix: iOS index not sync when back gesture.

## 0.2.1

- fix: crash case on f->n->f .

## 0.2.0

- feat: add flutter custom transition builder api.

## 0.1.8

- fix: ios memory leak

## 0.1.7

- fix: Android didn't notify after popTo
- fix: Android didn't call onPopResult from native pop to flutter

## 0.1.6

- fix: popResult 失败

## 0.1.5

- fix: url 带 . 时引起的冲突，issue #27

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

## 0.1.3

- fix: Android demo 原生页面和 Flutter 页面转场动画不一致
- fix: iOS hidesNavigationBar 设置后原生页面一直生效的 bug

## 0.1.2

- fix: iOS 下面 Dart 页面通知的 bug

## 0.0.1

- TODO: Describe initial release.
- fix: Android push always return index.
- fix: remove signle_top for Android native Activity.
