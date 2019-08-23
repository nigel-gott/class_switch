import 'package:dispatchable_annotation/dispatchable_annotation.dart';

part 'base.g.dart';

main() {
  print(FruitDispatcher.fruitDispatcher((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
}

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

@dispatchable
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}
