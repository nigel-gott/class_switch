[![Build Status](https://travis-ci.com/nigel-gott/class_switch.svg?branch=master)](https://travis-ci.com/nigel-gott/class_switch)

A dart code generator which allows you to work with sub classes in a safer manner.

## Usage


```dart
import 'package:class_switch_annotation/class_switch_annotation.dart';

part 'base.g.dart';

main() {
  // Prints 1.
  print(FruitSwitcher.fruitSwitcher((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
}

@class_switch
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}

class MyFruitHandler extends FruitSwitcher<int> {
  @override
  int apple(Apple apple) {
    return 1;
  }

  @override
  int orange(Orange orange) {
    return 2;
  }
}

```

