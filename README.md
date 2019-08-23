[![Build Status](https://travis-ci.com/nigel-gott/dispatchable.svg?branch=master)](https://travis-ci.com/nigel-gott/dispatchable)

A dart code generator which allows you to work with sub classes in a safer manner.

## Usage


```dart
import 'package:dispatchable_annotation/dispatchable_annotation.dart';

part 'base.g.dart';

main() {
  // Prints 1.
  print(FruitDispatcher.fruitDispatcher((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
}

@dispatchable
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}

class MyFruitHandler extends FruitDispatcher<int> {
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

