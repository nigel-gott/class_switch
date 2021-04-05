import 'package:class_switch/class_switch.dart';

part 'example.g.dart';

@ClassSwitch()
abstract class Fruit {}

class Apple extends Fruit {}

class Orange extends Fruit {}

void main() {
  var myFruit = Apple();
  var switchRun = myFruit.$switch(
          (apple) => 1,
          (orange) => 2
  );
  var switchRun = Fruit.$switchDefault(myFruit)(
          (apple) => 1,
      $default: (fruit) => 2
  );

  assert switchRun == 1;
  assert(MyFruitSwitcher().$switch(Orange()) == 2);
  assert(MyFruitHandlerWithADefault().$switchDefault(Orange())
  ==
  '
  orange is special
  '
  );
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
