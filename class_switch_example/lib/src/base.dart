import 'package:class_switch/class_switch.dart';

part 'base.g.dart';

main() {
  print(FruitSwitcher.fruitSwitcher((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
}

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

@class_switch
abstract class Fruit {}

class Apple extends Fruit {
}

class Orange extends Fruit {}

