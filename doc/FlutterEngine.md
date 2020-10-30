# Flutter 引擎管理

thrio 支持单引擎和多引擎两种模式，默认为单引擎模式。

## 单引擎模式

指的是在 App 中始终只启动一个
FlutterEngine，dart entrypoint 默认为`main`，默认会提前启动引擎。

开启单引擎模式，需在引擎启动之前调用如下代码

```objc
  [ThrioNavigator setMultiEngineEnabled:NO];
```

## 多引擎模式

指的是在一个 App 中允许启动多个 FlutterEngine，每个引擎的 dart entrypoint 不同。
entrypoint 根据路由 url 第一段解析得到，如：url `/biz1/flutter1`的 entrypoint 为`biz1`.
在 dart 代码中需要添加对应的 entrypoint：

```dart
@pragma('vm:entry-point')
Future<void> biz1() async {
  FlutterError.onError = (details) async {
    Zone.current.handleUncaughtError(details.exception, details.stack);
  };
  runZoned<void>(app.biz1);
}
```

### 优缺点

- 优点：允许 Dart 代码运行于不同的 Engine 中以达到物理上的异常隔离，方便区分异常职责
- 缺点：引擎消耗的资源比较大

### 适用的场景

- 多业务线的代码隔离，可以做到在一个 App 上，各个业务线的代码之间基本上是独立运行的，但是代码是在一块打包
- 类似小程序，用完即释放

### 实现方式

- 当要打开一个 Flutter 页面时，路由 url 的第一段解析为引擎的 entrypoint
- 根据 entrypoint 判断当前是否存在对应的引擎
  - 如不存在启动引擎，等待引擎启动 ready
  - 如果存在继续下一步
- 判断顶层的 UIViewController 或者 Activity 是否为当前引擎的容器页面
  - 如果是，向 Dart 发送打开页面的请求
  - 否则，新建容器页面，向 Dart 发送打开页面的请求，如果成功，则打开容器页面
