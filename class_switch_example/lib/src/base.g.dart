// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// **************************************************************************
// ClassSwitchGenerator
// **************************************************************************

abstract class FruitSwitcherWithDefault<T> {
  T acceptFruit(Fruit fruitInstance) {
    return FruitSwitcher.fruitSwitcher(apple, orange)(fruitInstance);
  }

  T defaultValue();

  T apple(Apple apple) {
    return defaultValue();
  }

  T orange(Orange orange) {
    return defaultValue();
  }
}

abstract class FruitSwitcher<T> {
  static T Function(Fruit) fruitSwitcher<T>(
      T Function(Apple) apple, T Function(Orange) orange) {
    return (fruitInstance) {
      if (fruitInstance is Apple) {
        return apple(fruitInstance);
      } else if (fruitInstance is Orange) {
        return orange(fruitInstance);
      } else {
        throw UnimplementedError(
            "Unknown class given to switcher: $fruitInstance. subClass code generation has done something incorrectly. ");
      }
    };
  }

  T acceptFruit(Fruit fruitInstance) {
    return fruitSwitcher(apple, orange)(fruitInstance);
  }

  T apple(Apple apple);
  T orange(Orange orange);
}
