import 'package:class_switch/class_switch.dart';

part 'example.g.dart';

@ClassSwitch()
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}

void main() {
  final myFruit = Apple();

  var result = myFruit.$switch(
      (apple) => 1, //
      (orange) => 2,);
  assert(result == 1);

  result = MyFruitSwitcher().$switch(Orange());
  assert(result == 2);

  final strResult = myFruit.$switch((apple) => 'x', (orange) => 'y');

  assert(strResult == 'x');
}

class MyFruitSwitcher extends _$FruitSwitcher<int> {
  @override
  int apple(Apple apple) {
    return 1;
  }

  @override
  int orange(Orange orange) {
    return 2;
  }
}

class MyFruitHandlerWithADefault extends _$FruitSwitcherWithDefault<String> {
  @override
  String defaultValue() {
    return 'default';
  }

  @override
  String orange(Orange orange) {
    return 'orange is special';
  }
}
