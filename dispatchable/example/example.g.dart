// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// DispatchableGenerator
// **************************************************************************

abstract class FruitDispatcherWithDefault<T> {
  T acceptFruit(Fruit fruitInstance) {
    return FruitDispatcher.fruitDispatcher(apple, orange)(fruitInstance);
  }

  T defaultValue();
  T apple(Apple apple) {
    return defaultValue();
  }

  T orange(Orange orange) {
    return defaultValue();
  }
}

abstract class FruitDispatcher<T> {
  T acceptFruit(Fruit fruitInstance) {
    return FruitDispatcher.fruitDispatcher(apple, orange)(fruitInstance);
  }

  static T Function(Fruit) fruitDispatcher<T>(
      T Function(Apple) apple, T Function(Orange) orange) {
    return (fruitInstance) {
      if (fruitInstance is Apple) {
        return apple(fruitInstance);
      } else if (fruitInstance is Orange) {
        return orange(fruitInstance);
      } else {
        throw ArgumentError(
            'Unknown class given to dispatchable: $fruitInstance. Have you added a new sub class for Fruit without running pub run build_runner build?. ');
      }
    };
  }

  T apple(Apple apple);
  T orange(Orange orange);
}
