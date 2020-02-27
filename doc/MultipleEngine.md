# 多引擎模式

多引擎模式指的是在一个 App 中允许启动多个 FlutterEngine，每个引擎的代码入口可以不同。

thrio 默认支持多引擎模式，如要关闭，需在`initModule`调用之前运行如下代码

```objc
  [ThrioNavigator setMultiEngineEnabled:NO];
```

## 优缺点及适用场景

- 优点：允许 Dart 代码运行于不同的 Engine 中以达到物理上的异常隔离，方便区分异常职责
- 缺点：引擎消耗的资源比较大
- 适用的场景：
  - 多业务线的代码隔离，比如 BOS App 上，各个业务线之间基本上是独立运行的，但是代码是在一块打包
  - 类似小程序，用完即释放

## 实现方式

- 当要打开一个 Flutter 页面时，路由 url 的第一段解析为引擎的 entrypoint
- 根据 entrypoint 判断当前是否存在对应的引擎
  - 如不存在启动引擎，等待引擎启动 ready
  - 如果存在继续下一步
- 判断顶层的 UIViewController 或者 Activity 是否为当前引擎的容器页面
  - 如果是，向 Dart 发送打开页面的请求
  - 否则，新建容器页面，向 Dart 发送打开页面的请求，如果成功，则打开容器页面
