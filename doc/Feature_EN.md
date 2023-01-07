# 

![thrio logo](./doc/imgs/thrio.png)

[![Gitter Channel][]][gitter badge] [![pub package](https://img.shields.io/pub/v/thrio.svg)](https://pub.dartlang.org/packages/thrio) [![license](https://img.shields.io/github/license/hellobike/thrio.svg?maxAge=2592000)](https://github.com/hellobike/thrio/LICENSE)

[中文文档](./doc/Feature.md) [问题集](./doc/Questions.md) QQ 群号码：1014085473

Flutter SDK 版本是 `1.22.x` 的，请用 `1.0.0` 及之后的版本。

The `Navigator` for iOS, Android, Flutter.

Version `0.5.1` requires Flutter `>= 1.12.1` and Dart `>= 2.6.0` .

## Features

* `push`,   `pop`,   `popTo`,   `remove` native pages or flutter pages from anywhere
* Get the callback parameters when the `push` page is `popped`
* Send and receive page notifications
* Register observers for the life cycle of pages
* Register observers for the route actions of pages
* Hide native navigation bar for flutter pages
* Supports custom transition animation on the Flutter side
* Supports running multiple entry points

## Getting started

You should ensure that you add `thrio` as a dependency in your flutter project.

``` yaml
dependencies:
  thrio: ^1.0.1
```

You can also reference the git repo directly if you want:

``` yaml
dependencies:
  thrio:
    git: git@github.com:hellobike/thrio.git
    ref: main
```

You should then run `flutter pub upgrade` or update your packages in IntelliJ.

## Example Project

There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

### `push` a page in dart

``` dart
ThrioNavigator.push(url: '/biz/biz1/flutter1');

ThrioNavigator.push(url: '/biz1/native1', params: { '1': {'2': '3'}});

ThrioNavigator.push(url: '/biz1/native1', animated:true);

ThrioNavigator.push(
    url: '/biz/biz2/flutter2',
    params: {'1': {'2': '3'}},
    poppedResult: (params) => verbose('/biz2/flutter2 popped: $params'),
);
```

### `push` a page in iOS

``` objc
[ThrioNavigator pushUrl:@"/biz/biz1/flutter1"];

[ThrioNavigator pushUrl:@"/biz/biz2/flutter2" poppedResult:^(id _Nonnull params) {
    ThrioLogV(@"/biz2/flutter2 popped: %@", params);
}];
```

### `push` a page in Android

``` kotlin
ThrioNavigator.push("/biz/biz1/flutter1",
        mapOf("k1" to 1),
        false,
        poppedResult = {
            Log.e("Thrio", "/biz1/native1 popResult call params $it")
        }
)
```

### `pop` a page in dart

``` dart
ThrioNavigator.pop();
// Pop the page without animation
ThrioNavigator.pop(animated: false);
// Pop the page and return parameters
ThrioNavigator.pop(params: 'popped flutter1'),
```

### `pop` a page in iOS

``` objc
[ThrioNavigator pop];
// Pop a page without animation
[ThrioNavigator popAnimated:NO];
// Pop the page and return parameters
[ThrioNavigator popParams:@{@"k1": @3}];
```

### `pop` a page in Android

``` kotlin
ThrioNavigator.pop(params, animated)
```

### `popTo` a page in dart

``` dart

ThrioNavigator.popTo(url: '/biz/biz1/flutter1');

ThrioNavigator.popTo(url: '/biz/biz1/flutter1', animated: false);
```

### `popTo` a page in iOS

``` objc
[ThrioNavigator popToUrl:@"/biz/biz1/flutter1"];

[ThrioNavigator popToUrl:@"/biz/biz1/flutter1" animated:NO];
```

### `popTo` a page in Android

``` kotlin
ThrioNavigator.popTo(url, index)
```

### `remove` a page in dart

``` dart
ThrioNavigator.remove(url: '/biz/biz1/flutter1');

ThrioNavigator.remove(url: '/biz/biz1/flutter1', animated: true);
```

## `remove` a page in iOS

``` objc
[ThrioNavigator removeUrl:@"/biz/biz1/flutter1"];

[ThrioNavigator removeUrl:@"/biz/biz1/flutter1" animated:NO];
```

### `remove` a page in Android

``` kotlin
ThrioNavigator.remove(url, index)
```

### `notify` a page in dart

``` dart
ThrioNavigator.notify(url: '/biz/biz1/flutter1', name: 'reload');
```

### `notify` a page in iOS

``` objc
[ThrioNavigator notifyUrl:@"/biz/biz1/flutter1" name:@"reload"];
```

### `notify` a page in Android

``` kotlin
ThrioNavigator.notify(url, index, params)
```

### receive page notifications in dart

``` dart
NavigatorPageNotify(
      name: 'page1Notify',
      onPageNotify: (params) =>
          verbose('flutter1 receive notify: $params'),
      child: Xxxx());
```

### receive page notifications in iOS

`UIViewController` implements the `NavigatorPageNotifyProtocol` and receives page notifications via `onNotify`

``` objc

* (void)onNotify:(NSString *)name params:(id)params {

  ThrioLogV(@"/biz1/native1 onNotify: %@, %@", name, params);
}
```

### receive page notifications in Android

`Activity` implements the `PageNotifyListener` and receives page notifications via `onNotify`

``` kotlin
class Activity : AppCompatActivity(), PageNotifyListener {
    override fun onNotify(name: String, params: Any?) {
    }
}
```

[gitter channel]: https://badges.gitter.im/flutter_thrio/flutter_thrio.svg
[gitter badge]: https://gitter.im/flutter_thrio/flutter_thrio?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
