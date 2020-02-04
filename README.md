# flutter 路由库 thrio 指南

thrio 是一个支持 flutter 嵌入原生应用的路由库，目前只有 iOS 版本可看，Android 版本在开发中。

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
ThrioApp().registerPageBuilder(
  'flutter1',
  (settings) => Page1(
    index: settings.index,
    params: settings.params,
  ),
);
```

2. iOS 中注册页面路由

```objc
  [ThrioApp.shared registerNativeViewControllerBuilder:^UIViewController * _Nullable(NSDictionary<NSString *,id> * _Nonnull params) {
    return UIViewController...
  } forUrl:@"native1"];

```

### 打开页面

1. Dart 端打开页面

```dart
ThrioNavigator.push(url: 'flutter1');
// 传入参数
ThrioNavigator.push(url: 'native1', params: { '1': {'2': '3'}});
// 是否动画，目前在内嵌的dart页面中动画无法取消，原生iOS页面有效果
ThrioNavigator.push(url: 'native1', animated:true);
```

2. iOS 端打开页面

```objc
[ThrioNavigator.shared pushUrl:@"flutter1"];
```

### 关闭顶层页面

1. dart 端关闭顶层页面

```dart
// 默认动画开启
ThrioNavigator.pop();
// 不开启动画，原生和dart页面都生效
ThrioNavigator.pop(animated: false);
```

2. iOS 端关闭顶层页面

```objc
// 默认动画开启
[ThrioNavigator.shared pop];
// 关闭动画
[ThrioNavigator.shared popAnimated:NO];
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
[ThrioNavigator.shared popToUrl:@"flutter1"];
// 关闭动画
[ThrioNavigator.shared popToUrl:@"flutter1" animated:NO];
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
[ThrioNavigator.shared removeUrl:@"flutter1"];
// 只有当页面是顶层页面时，animated参数才会生效
[ThrioNavigator.shared removeUrl:@"flutter1" animated:NO];
```

### 给特定页面发通知

给一个页面发送通知，只有当页面呈现之后才会收到该通知。

1. dart 端给特定页面发通知

```dart
ThrioNavigator.notify(url: 'flutter1', name: 'reload');
```

2. iOS 端给特定页面发通知

```objc
[ThrioNavigator.shared notifyUrl:@"flutter1" name:@"reload"];
```

### Flutter 页面导航栏自动隐藏

实际上实现了 UIViewController 的分类扩展，FlutterViewController 强制设为 YES，原生页面设置导航栏隐藏，也很简单

```objc
viewController.thrio_hidesNavigationBar = NO;
```

### iOS 的 FlutterViewController 支持侧滑返回

FlutterViewController 默认是不支持侧滑返回的，因为 thrio 支持一个 FlutterViewController 可以打开任意多个 dart 页面，dart 页面本身也是要支持侧滑返回的，手势上存在一定的冲突，在这里 thrio 做了一些特殊处理，基本上支持无缝切换。有兴趣可以参看源码实现。

### 原生页面和 dart 页面支持页面禁止关闭

1. dart 端禁止特定页面关闭

```dart
ThrioNavigator.setPopDisabled(url: 'flutter1');
```

2. iOS 端禁止特定页面关闭

```objc
[ThrioNavigator.shared setPopDisabledUrl:@"flutter1" disabled:NO];
```

在 dart 端依然支持通过 WillPopScope 来设置禁止页面返回。

### 支持 FlutterViewController 内嵌套 Dart 页面

这个点非常重要，在 iOS 中如果每打开一个 dart 页面都切换一个新的 FlutterViewController，每个页面多消耗 12M+以上的内存，内存消耗是非常恐怖的，这是目前 flutter_boost 的实现方式。
