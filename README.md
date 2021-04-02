[![Build Status](https://travis-ci.com/nigel-gott/dispatchable.svg?branch=master)](https://travis-ci.com/nigel-gott/dispatchable)

A dart code generator which allows you to work with sub classes in a safer manner.

A class annotated with @dispatchable will have two different dispatcher classes 
generated:
* `{AnnotatedClassName}Dispatcher<T>` which has abstract methods for each sub-class of the annotated class.
  * This class will also have a static method `dispatcher`
* `{AnnotatedClassName}DispatcherWithDefaults<T>` which has methods for each sub-class 
  of the annotated class returning the abstract method default.

## Setup

## Usage


```dart
import 'package:dispatchable/dispatchable.dart';

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

