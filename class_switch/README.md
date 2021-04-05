[![Build Status](https://travis-ci.com/nigel-gott/class_switch.svg?branch=master)](https://travis-ci.com/nigel-gott/class_switch)

A dart code generator which allows you to work with sub classes in a safer manner.

A class annotated with @ClassSwitch() will have two different dispatcher classes generated:
* `_${AnnotatedClassName}Dispatcher<T>` which has abstract methods for each sub-class of the annotated class.
  * This class will also have a static method `dispatcher`
* `_${AnnotatedClassName}DispatcherWithDefaults<T>` which has methods for each sub-class of the annotated class returning the abstract method default.

## Setup

## Usage


```dart
import 'package:class_switch/class_switch.dart';

part 'base.g.dart';

main() {
  // Prints 1.
  print(_$FruitDispatcher.acceptFunc((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
}

@ClassSwitch()
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}

class MyFruitHandler extends _$FruitDispatcher<int> {
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

