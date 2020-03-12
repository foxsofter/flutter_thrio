# thrio

thrio 是一个支持 flutter 嵌入原生应用的路由库，目前只有 iOS 版本可看，Android 版本在开发中。

[引擎管理](./doc/FlutterEngine.md)

## 为什么写 thrio

thrio 的诞生主要是为了解决我们自身的业务问题。

我们目前积累了将近 10 万行 Dart 业务代码，早期的时候采用 flutter_boost 提供的解决方案来实现将 Flutter 嵌入原生应用，使用过程中也积累了很多对 flutter_boost 改造的需求，但因为 flutter_boost 的路线图短期或者长期都看不到能满足我们这些需求的可能，所以我们只好自己造了一个轮子。

## 需求是什么

1. 三端统一的打开页面的接口，至少支持 push，支持多开页面实例，flutter_boost 支持
2. 三端统一的关闭页面的接口，至少支持关闭顶层页面，关闭特定页面，关闭到特定页面，flutter_boost 支持前两点，第三点不支持
3. 三端统一的页面间通知的接口，一定要支持特定页面间的通知传递，flutter_boost 支持不好，无法满足特定页面间的通知传递
4. dart 页面导航栏自动隐藏，且不影响原生页面的导航栏，flutter_boost 不支持，需要自行扩展
5. iOS 的 FlutterViewController 要支持侧滑返回，flutter_boost 不支持
6. 原生页面和 dart 页面要支持页面禁止关闭，flutter_boost 支持了 dart 页面，但页面动画缺失
7. 支持 FlutterViewController 内嵌套 Dart 页面，flutter_boost 的支持非常弱

**以上对 flutter_boost 的一些判断可能不准确，仅做对比。**

## thrio 提供的功能

### 注册页面路由

1. dart 中注册页面路由

```dart
class Module with ThrioModule {
  @override
  void onPageRegister() {
    registerPageBuilder(
      'flutter3',
      (settings) => Page3(index: settings.index, params: settings.params),
    );
    registerPageBuilder(
      'flutter4',
      (settings) => Page4(index: settings.index, params: settings.params),
    );
  }
}
```

2. iOS 中注册页面路由

```objc
- (void)onPageRegister {
  [self registerNativeViewControllerBuilder:^UIViewController * _Nullable(NSDictionary<NSString *,id> * _Nonnull params) {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"ThrioViewController"];
  } forUrl:@"native1"];
}
```

3. Android 中注册页面路由

打开操作逻辑需要实现`NavigationBuilder`接口

```kotlin
ThrioNavigator.registerNavigationBuilder("native1", object : NavigationBuilder {
    override fun getActivityClz(url: String): Class<out Activity> {
        return Native2Activity::class.java
    }
})
```

### 打开页面

1. Dart 端打开页面

```dart
ThrioNavigator.push(url: 'flutter1');
// 传入参数
ThrioNavigator.push(url: 'native1', params: { '1': {'2': '3'}});
// 是否动画，目前在内嵌的dart页面中动画无法取消，原生iOS页面有效果
ThrioNavigator.push(url: 'native1', animated:true);
// 接收锁打开页面的关闭回调
ThrioNavigator.push(
    url: 'biz2/flutter2',
    params: {'1': {'2': '3'}},
    poppedResult: (params) => ThrioLogger().v('biz2/flutter2 popped: $params'),
);
```

2. iOS 端打开页面

```objc
[ThrioNavigator pushUrl:@"flutter1"];
// 接收所打开页面的关闭回调
[ThrioNavigator pushUrl:@"biz2/flutter2" poppedResult:^(id _Nonnull params) {
    ThrioLogV(@"biz2/flutter2 popped: %@", params);
}];
```

3. Android 端打开页面

TODO: poppedResult暂未实现，回调会超出页面生命周期

```kotlin
ThrioNavigator.push(context, "flutter1", params)
```

### 关闭顶层页面

1. dart 端关闭顶层页面

```dart
// 默认动画开启
ThrioNavigator.pop();
// 不开启动画，原生和dart页面都生效
ThrioNavigator.pop(animated: false);
// 关闭当前页面，并传递参数给push这个页面的回调
ThrioNavigator.pop(params: 'popped flutter1'),
```

2. iOS 端关闭顶层页面

```objc
// 默认动画开启
[ThrioNavigator pop];
// 关闭动画
[ThrioNavigator popAnimated:NO];
// 关闭当前页面，并传递参数给push这个页面的回调
[ThrioNavigator popParams:@{@"k1": @3}];
```

3. Android 端关闭顶层页面

```kotlin
ThrioNavigator.pop(context, animated)
```

### 关闭到页面

1. dart 端关闭到页面

```dart
// 默认动画开启
ThrioNavigator.popTo(url: 'flutter1');
// 不开启动画，原生和dart页面都生效
ThrioNavigator.popTo(url: 'flutter1', animated: false);
```

2. iOS 端关闭到页面

```objc
// 默认动画开启
[ThrioNavigator popToUrl:@"flutter1"];
// 关闭动画
[ThrioNavigator popToUrl:@"flutter1" animated:NO];
```


3. Android 端关闭到页面

```kotlin
ThrioNavigator.popTo(context, url, index)
```


### 关闭特定页面

1. dart 端关闭特定页面

```dart
ThrioNavigator.remove(url: 'flutter1');
// 只有当页面是顶层页面时，animated参数才会生效
ThrioNavigator.remove(url: 'flutter1', animated: true);
```

2. iOS 端关闭特定页面

```objc
[ThrioNavigator removeUrl:@"flutter1"];
// 只有当页面是顶层页面时，animated参数才会生效
[ThrioNavigator removeUrl:@"flutter1" animated:NO];
```

3. Android 端关闭特定页面

```kotlin
ThrioNavigator.remove(context, url, index)
```

### 给特定页面发通知

给一个页面发送通知，只有当页面呈现之后才会收到该通知。

1. dart 端给特定页面发通知

```dart
ThrioNavigator.notify(url: 'flutter1', name: 'reload');
```

2. iOS 端给特定页面发通知

```objc
[ThrioNavigator notifyUrl:@"flutter1" name:@"reload"];
```

3. Android 端给特定页面发通知

```kotlin
ThrioNavigator.notify(url, index, params)
```

### 页面接收通知

1. dart 端接收页面通知

使用`NavigatorPageNotify`这个 Widget 来实现在任何地方接收当前页面收到的通知。

```dart
NavigatorPageNotify(
      name: 'page1Notify',
      onPageNotify: (params) =>
          ThrioLogger().v('flutter1 receive notify: $params'),
      child: Xxxx());
```

2. iOS 端接收页面通知

`UIViewController`实现协议`NavigatorPageNotifyProtocol`，通过该协议定义的方法来接收页面通知

```objc
- (void)onNotify:(NSString *)name params:(NSDictionary *)params {
  ThrioLogV(@"native1 onNotify: %@, %@", name, params);
}
```

3. Android 端接收页面通知
   
`Activity`实现协议`OnNotifyListener`，通过onNotify回调来接收页面通知
TODO: url, index 需要去除

```kotlin
class Activity : AppCompatActivity(), OnNotifyListener {
    override fun onNotify(url: String, index: Int, name: String, params: Any?) {
    }
}
```


### Flutter 页面导航栏自动隐藏

实际上实现了 UIViewController 的分类扩展，FlutterViewController 强制设为 YES，原生页面设置导航栏隐藏，也很简单

```objc
viewController.thrio_hidesNavigationBar = NO;
```

### iOS 的 FlutterViewController 支持侧滑返回

FlutterViewController 默认是不支持侧滑返回的，因为 thrio 支持一个 FlutterViewController 可以打开任意多个 dart 页面，dart 页面本身也是要支持侧滑返回的，手势上存在一定的冲突，在这里 thrio 做了一些特殊处理，基本上支持无缝切换。有兴趣可以参看源码实现。

### 原生页面和 dart 页面支持页面关闭前调用闭包

每个端各自维护自身的页面，不支持跨端传递闭包逻辑

1. dart 端禁止特定页面关闭

```dart
WillPopScope(
    onWillPop: () async => true,
    child: Container(),
);
```

2. iOS 端禁止特定页面关闭

```objc
viewController.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
  result(NO);
};
```

一旦设置 thrio_willPopBlock，侧滑返回将失效.

### 支持内嵌套 Flutter 页面

这是谷歌推荐的实现方式，导航栈中不被原生页面分隔的所有 Flutter 页面共用一个原生的容器页面，有效减少内存消耗量。

1. iOS 端

原来的方案是每打开一个Flutter页面会创建一个新的原生页面，比如以连续打开5个Flutter页面计算（比较接近目前我们在项目上的场景），iOS会消耗91.67M内存，新方案iOS只消耗42.76内存，页面打开内存消耗数据大致如下：

| demo  | 启动 | 页面1 | 页面2 | 页面3 | 页面4 | 页面5 |
| ----- | ---- | ----- | ----- | ----- | ----- | ----- |
| thrio | 8.56 | 37.42 | 38.88 | 42.52 | 42.61 | 42.76 |
| boost | 6.81 | 36.08 | 50.96 | 66.18 | 78.86 | 91.67 |