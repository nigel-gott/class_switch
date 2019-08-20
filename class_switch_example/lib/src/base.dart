//import 'package:class_dispatcher/class_dispatcher.dart';

part 'base.g.dart';

main() {
  print(FruitHandler.fruitHandler((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));
}

class MyFruitHandler extends FruitHandler<int> {
  @override
  int apple(Apple apple) {
    // TODO: implement apple
    return null;
  }

  @override
  int orange(Orange orange) {
    // TODO: implement orange
    return null;
  }
}

//@Subtype()
class Fruit {}

class Apple extends Fruit {
  int imAnApple() => 1;
}

//@Subtype()
class Orange extends Fruit {}

class A extends Orange {}

//@Subtype()
class X {}

class Y extends X {}

//@CrossSubtype()
abstract class State {}

class StateA extends State {}

class StateB extends State {}

//@CrossSubtype()
abstract class Event {}

class EventA extends Event {}

class EventB extends Event {}
