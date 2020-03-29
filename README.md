![Name](./docs/imgs/thrio.png)
<br/><br/>

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
 thrio: "^0.1.0"
```

You can also reference the git repo directly if you want:
```yaml
dependencies:
 fluro:
   git: git@github.com:hellobike/thrio.git
```

You should then run `flutter pub upgrade` or update your packages in IntelliJ.

## Example Project

There is a pretty sweet example project in the `example` folder. Check it out. Otherwise, keep reading to get up and running.

[README CN](./docs/Feature.md)