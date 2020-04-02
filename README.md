# ![thrio logo](./docs/imgs/thrio.png)

[![Gitter Channel][]][gitter badge]

The `Navigator` for iOS, Android, Flutter.

Version `0.1.0` requires Flutter `>= 1.12.0` and Dart `>= 2.6.0`.

## Features

- `push`,`pop`,`popTo`,`remove` native pages or flutter pages from anywhere
- Get the callback parameters when the `push` page is `popped`
- Send and receive page notifications
- Register observers for the life cycle of pages
- Register observers for the route actions of pages
- Hide native navigation bar for flutter pages

## Getting started

You should ensure that you add `thrio` as a dependency in your flutter project.

```yaml
dependencies:
  thrio: '^0.1.0'
```

You can also reference the git repo directly if you want:

```yaml
dependencies:
  thrio:
    git: git@github.com:hellobike/thrio.git
```

You should then run `flutter pub upgrade` or update your packages in IntelliJ.

## Example Project

There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

[README CN](./docs/Feature.md)

### `push` a page in dart

```dart
ThrioNavigator.push(url: 'flutter1');

ThrioNavigator.push(url: 'native1', params: { '1': {'2': '3'}});

ThrioNavigator.push(url: 'native1', animated:true);

ThrioNavigator.push(
    url: 'biz2/flutter2',
    params: {'1': {'2': '3'}},
    poppedResult: (params) => ThrioLogger.v('biz2/flutter2 popped: $params'),
);
```

### `push` a page in iOS

```objc
[ThrioNavigator pushUrl:@"flutter1"];

[ThrioNavigator pushUrl:@"biz2/flutter2" poppedResult:^(id _Nonnull params) {
    ThrioLogV(@"biz2/flutter2 popped: %@", params);
}];
```

### `push` a page in Android

```kotlin
ThrioNavigator.push(this, "biz1/flutter1",
        mapOf("k1" to 1),
        false,
        poppedResult = {
            Log.e("Thrio", "native1 popResult call params $it")
        }
)
```

### `pop` a page in dart

```dart
ThrioNavigator.pop();
// Pop the page without animation
ThrioNavigator.pop(animated: false);
// Pop the page and return parameters
ThrioNavigator.pop(params: 'popped flutter1'),
```

### `pop` a page in iOS

```objc
[ThrioNavigator pop];
// Pop a page without animation
[ThrioNavigator popAnimated:NO];
// Pop the page and return parameters
[ThrioNavigator popParams:@{@"k1": @3}];
```

### `pop` a page in Android

```kotlin
ThrioNavigator.pop(this, params, animated)
```

### `popTo` a page in dart

```dart

ThrioNavigator.popTo(url: 'flutter1');

ThrioNavigator.popTo(url: 'flutter1', animated: false);
```

### `popTo` a page in iOS

```objc
[ThrioNavigator popToUrl:@"flutter1"];

[ThrioNavigator popToUrl:@"flutter1" animated:NO];
```

### `popTo` a page in Android

```kotlin
ThrioNavigator.popTo(context, url, index)
```

### `remove` a page in dart

```dart
ThrioNavigator.remove(url: 'flutter1');

ThrioNavigator.remove(url: 'flutter1', animated: true);
```

## `remove` a page in iOS

```objc
[ThrioNavigator removeUrl:@"flutter1"];

[ThrioNavigator removeUrl:@"flutter1" animated:NO];
```

### `remove` a page in Android

```kotlin
ThrioNavigator.remove(context, url, index)
```

### `notify` a page in dart

```dart
ThrioNavigator.notify(url: 'flutter1', name: 'reload');
```

### `notify` a page in iOS

```objc
[ThrioNavigator notifyUrl:@"flutter1" name:@"reload"];
```

### `notify` a page in Android

```kotlin
ThrioNavigator.notify(url, index, params)
```

### receive page notifications in dart

```dart
NavigatorPageNotify(
      name: 'page1Notify',
      onPageNotify: (params) =>
          ThrioLogger.v('flutter1 receive notify: $params'),
      child: Xxxx());
```

### receive page notifications in iOS

`UIViewController` implements the `NavigatorPageNotifyProtocol` and receives page notifications via `onNotify`

```objc
- (void)onNotify:(NSString *)name params:(NSDictionary *)params {
  ThrioLogV(@"native1 onNotify: %@, %@", name, params);
}
```

### receive page notifications in Android

`Activity` implements the `OnNotifyListener` and receives page notifications via `onNotify`

```kotlin
class Activity : AppCompatActivity(), OnNotifyListener {
    override fun onNotify(name: String, params: Any?) {
    }
}
```

[gitter channel]: https://badges.gitter.im/flutter_thrio/flutter_thrio.svg
[gitter badge]: https://gitter.im/flutter_thrio/flutter_thrio?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
