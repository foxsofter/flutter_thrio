# Q & A

## 为什么写 thrio

thrio 的出现主要是解决以下问题：

* Flutter 页面嵌入原生应用内存占用过多的问题，具体参考[中文文档](Feature.md###总结)，以及 [issue](https://github.com/alibaba/flutter_boost/issues/933#issuecomment-742925481)；

* 提供更完整且三端一致的路由 API；

* 提供页面通知的 API；

* 还有其它的附加的功能，后续会完整开放多引擎模式；

## 页面通知与页面关闭回调分别应该怎么用

* 页面通知的使用场景比较灵活，只要你知道具体的页面 url，都可以给该页面发送一个通知，当且仅当接收页面的通知呈现的时候才会收到通知；

* 页面的关闭回调，一个常见的场景是，一个选择器页面，选择了之后马上关闭掉，但是需要回调选择了什么给打开页面的 `push` 函数。当然这种场景你也可以使用页面通知，但如果你连哪个页面打开选择器页面都不知道的时候，唯一的选择就是页面关闭回调。

## 页面回调是否支持跨端

页面回调支持跨端，thrio 所有的 API 基本都是支持跨端的，你可以在原生页面打开一个 Dart 页面，当这个 Dart 页面 pop 时可以传参给原生的 `push` 函数的页面关闭回调。

## 关于页面生命周期能否解释下

页面生命周期，在原生端，一般只有原生页面的页面生命周期，Dart 端也只有进行一些改造才有 Dart 页面的生命周期，但我们很多时候需要在原生端能得到所有页面的生命周期，比如页面埋点

## iOS 中如果要 `present` 一个 `UIViewController` 应该怎么办

thrio 暂时不支持 present，因为很难保持三端路由 API 的一致性，且 `present` 可以通过 `push` 模拟，禁用侧滑返回手势，替换转场动画来实现也是可以的。

## 我有一个场景，判断一个页面是否打开，如果打开则给其发送通知，如果未打开则打开并发送通知，如何实现

首先，thrio 提供的 `notify` 函数会有 bool 返回值，如果页面不存在就返回 `false` ，在 dart 中实现的方式如下：

```dart
InkWell(
    onTap: () async {
    if (!await ThrioNavigator.notify(
        url: '/biz/biz1/flutter1',
        name: 'page1Notify',
    )) {
        await ThrioNavigator.push(
            url: '/biz/biz1/flutter1', params: {'page1Notify': {}});
    }
    },
    child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        color: Colors.grey,
        child: Text(
        'open if needed and notify',
        style: TextStyle(fontSize: 22, color: Colors.black),
        )),
),
```

在接收页面通知的地方这样处理，

```dart
NavigatorPageNotify(
      name: 'page1Notify',
      initialParams: widget.params['page1Notify'],
      onPageNotify: (params) =>
          verbose('flutter1 receive notify:$params'),
      …
);
```

## 如何打开日志

默认路由日志都是关闭的，在 debug 下可以打开日志

1. 在 iOS 中需要添加预编译宏 `NAVIGATOR_LOGGING=1`，要在 Pods 工程上加才有效果
2. 在 dart 中设置 `navigatorLogEnabled = true;`
3. 在 Android 中设置 `navigatorLogEnabled = true`

## 如何在不同页面间传递 json object

thrio 支持在iOS, Android, Flutter 页面间传递 json object，传入方需要注册 json serializer 来让框架可以序列化，接收方需要注册 json deserializer 来让框架可以反序列化

1. dart 端的用法如下

```dart
@override
void onJsonSerializerRegister(ModuleContext moduleContext) {
    registerJsonSerializer<People>((instance) => instance<People>().toJson());
}

@override
void onJsonDeserializerRegister(ModuleContext moduleContext) {
    registerJsonDeserializer((arguments) => People.fromJson(arguments));
}
```

2. iOS 端的代码如下

```objc

- (void)onJsonSerializerRegister {

    [self registerJsonSerializer:^NSDictionary *_Nullable (id params) {
        return [params toJson];
    } forClass:THRPeople.class];

}

- (void)onJsonDeserializerRegister {

    [self registerJsonDeserializer:^id _Nullable(NSDictionary *params) {
        return [THRPeople fromJson:params];
    } forClass:THRPeople.class];

}
```

3. Android 端的代码如下

```kotlin
override fun onJsonSerializerRegister(context: Context) {
    registerJsonSerializer({ people -> people.toJson() }, People::class.java)
}

override fun onJsonDeserializerRegister(context: Context) {
    registerJsonDeserializer({ json -> People(json) }, People::class.java)
}
```

4. 在任何使用的地方，都可以传入 json object，比如 push 的 params 参数

## 给所有页面发送通知

通过 `notify` 接口就可以实现，只要不传入 `url` 就会给所有页面都发送

