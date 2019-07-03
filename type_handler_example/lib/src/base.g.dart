// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// **************************************************************************
// TypeHandlerGenerator
// **************************************************************************

Function(Fruit) fruitHandler<T>(
    T Function(Apple) appleHandler, T Function(Orange) orangeHandler) {
  return (fruit) {
    if (fruit is Apple) {
      return appleHandler(fruit);
    } else if (fruit is Orange) {
      return orangeHandler(fruit);
    } else {
      throw UnimplementedError(
          "Unknown class given to handler: $fruit. You must annotate every subtype of Fruit with @Subtype. ");
    }
  };
}

Function(Orange) orangeHandler<T>(T Function(A) aHandler) {
  return (orange) {
    if (orange is A) {
      return aHandler(orange);
    } else {
      throw UnimplementedError(
          "Unknown class given to handler: $orange. You must annotate every subtype of Orange with @Subtype. ");
    }
  };
}

Function(X) xHandler<T>(T Function(Y) yHandler) {
  return (x) {
    if (x is Y) {
      return yHandler(x);
    } else {
      throw UnimplementedError(
          "Unknown class given to handler: $x. You must annotate every subtype of X with @Subtype. ");
    }
  };
}
