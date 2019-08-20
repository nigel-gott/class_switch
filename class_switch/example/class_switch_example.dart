import 'package:class_switch/class_switch.dart';

main() {
  print(fruitHandler((apple) {
    return 1;
  }, (orange) {
    return 2;
  })(Apple()));

  print(MyHandler().handle(Orange()));
  print(MyHandler().handle(Apple()));
}

Function(Fruit) fruitHandler<T>(
    T Function(Apple) apple, T Function(Orange) orange) {
  return (fruit) {
    if (fruit is Apple) {
      return apple(fruit);
    } else if (fruit is Orange) {
      return orange(fruit);
    } else {
      throw UnimplementedError(
          "Unknown class given to handler: $fruit. You must annotate every subtype. ");
    }
  };
}

class MyHandler extends FruitHandlerWithDefault<int> {
  @override
  int defaultResult() {
    return 2;
  }

  @override
  int apple(Apple apple) {
    return 3;
  }
}

abstract class FruitHandler<T> {
  T handle(Fruit fruit) {
    return fruitHandler(apple, orange)(fruit);
  }

  T apple(Apple apple);

  T orange(Orange orange);
}

abstract class FruitHandlerWithDefault<T> {
  T handle(Fruit fruit) {
    return fruitHandler(apple, orange)(fruit);
  }

  T apple(Apple apple) {
    return defaultResult();
  }

  T orange(Orange orange) {
    return defaultResult();
  }

  T defaultResult();
}

class Fruit {}

@Subtype()
class Apple extends Fruit {}

@Subtype()
class Orange extends Fruit {}

@CrossSubtype()
abstract class State {}

class StateA extends State {}

class StateB extends State {}

@CrossSubtype()
abstract class Event {}

class EventA extends Event {}

class EventB extends Event {}



abstract class StateAndEventHandler<T>{
  T handleStateAndEvent(State state,Event event){
    if(state is StateA){
      if(event is EventA){
        return handleStateAEventA(state, event);
      }
      if(event is EventB){
        return handleStateAEventB(state, event);
      }
    }
    if(state is StateB){
      if(event is EventA){
        return handleStateBEventA(state, event);
      }
      if(event is EventB){
        return handleStateBEventB(state, event);
      }
    }
    return null;

  }


  T handleStateAEventA(StateA state, EventA event);
  T handleStateAEventB(StateA state, EventB event);
  T handleStateBEventA(StateB state, EventA event);
  T handleStateBEventB(StateB state, EventB event);

}
