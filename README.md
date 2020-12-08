#

![thrio logo](./doc/imgs/thrio.png)

[![pub package](https://img.shields.io/pub/v/thrio.svg)](https://pub.dartlang.org/packages/thrio)
[![license](https://img.shields.io/github/license/hellobike/thrio.svg?maxAge=2592000)](https://github.com/hellobike/thrio/LICENSE)

[中文文档](./doc/Feature.md) [英文文档](./doc/Feature_EN.md) [问题集](./doc/Questions.md) QQ 群号码：1014085473

## 优势

01. 支持 `FlutterEngine` 的复用，还支持 `FlutterViewController` 和 `FlutterActivity` 的复用，这保证了 `Flutter` 混合栈框架在内存占用上是最优解
02. 在 1 情形下，支持 **跨栈路由** 的能力，这是目前唯一能做到的 Flutter混合栈开源框架
03. 在 1 情形下，除了提供 `push` 和 `pop`，也提供了 `remove` 和 `popTo` 的能力，目前唯一能做到的 Flutter混合栈开源框架
04. 在 1 情形下，提供页面通知的能力，组合 `push` 和 `pop` 的路由传参能力，可以让状态参数在页面间传递，省去很多 channel 通讯的必要
05. 在 4 情形下，页面传参支持Json对象类型
06. 在 1 情形下，支持完整的页面生命周期
07. 在 1 情形下，支持完整的路由周期
08. 在 1 情形下，支持多引擎模式，可以在一个原生 `App` 中运行多份 `Flutter` 代码，目前唯一能做到的 `Flutter` 混合栈开源框架
09. 在 1 情形下，解决 iOS 和 Android 上的侧滑返回手势冲突
10. iOS 上自动隐藏 `Flutter` 页面的导航栏
11. 额外的支持三端统一的模块化方式，更好的与路由API配合

## 劣势

01. 在 iOS 上不支持 `present`，技术上完全可以实现，甚至使用者可以通过传参的方式在 `builder` 中自己 `present`，但为了 API 设计上统一，作者选择不支持  `present`，demo 中其实是有 `present` 的示例的，建议 `present` 的时候外套一个 `UINavigationController`，可以保证不管何时 `push` 时 API 都是有效的，flutter_thrio 时支持多 `UINavigationController` 的，有一点需要注意的是，如果多个 `UINavigationController` 内嵌于 `UITabBar` 中时，要注意无法同时将多个 `FlutterViewController` 呈现，不支持是因为支持的话无法进行引擎复用。
02. 在 Android 上不支持 `Fragment`，原因是复杂性无法解决，作者目前不能够保证提供一个通用稳定的版本。

## 入门

01. clone thrio 的源码，查看 demo，并运行起来
02. 通过 pub 引入 thrio，建议采用 1.0.0 之后的版本，之前的版本支持1.22.x之前的Flutter SDK，但不建议继续采用这些老版本的 SDK，还是尽快升级到新版
03. 模仿 thrio demo 中的源码，在现有工程上加入相关代码
04. 不要继承 Flutter SDK 中的一些类，比如 `FlutterViewController`、`FlutterActivity`、`FlutterAppDelegate` 等
05. 不要调用 `GeneratedPluginRegistrant` 的 `registerWithRegistry` 方法了，因为框架会自动调用

## 最后

01. 技术没有好与不好，使用在适合的场景才是最好的。

02. Flutter 在 客户端的适用场景会越来越广，个人比较看好。

03. 目前在移动端，一个好的 Flutter 混合栈框架是必须的，让你可以在大多数的页面上采用 Flutter 来开发从而达到提效的目的，少数涉及到 Flutter 不能很好支持的页面上继续使用原生开发，从而规避的 Flutter 的坑。

04. 如果所开发的是一个全新的 App，以后也不会涉及到老的代码的复用，或者不会涉及到 Flutter 支持不够良好的一些技术上的坑，确实可以考虑纯 Flutter。

05. 但4的情形极少，所以大部分的 Flutter 在引入的时候，都应该考虑以 Flutter 混合栈的方式进行，坑不是用来踩的，而是绕道而过。

[gitter channel]: https://badges.gitter.im/flutter_thrio/flutter_thrio.svg
[gitter badge]: https://gitter.im/flutter_thrio/flutter_thrio?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
