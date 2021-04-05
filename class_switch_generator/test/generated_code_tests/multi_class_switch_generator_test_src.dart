import 'package:class_switch/class_switch.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
abstract class _$TargetClassDispatcherWithDefault<T> {
  T accept(Base base, OtherBase otherBase) {
    return _$TargetClassDispatcher.acceptFunc(
        aOtherA, aOtherB, bOtherA, bOtherB)(base, otherBase);
  }

  T defaultValueA() {
    return defaultValue();
  }

  T defaultValueB() {
    return defaultValue();
  }

  T defaultValue();
  T aOtherA(A a, OtherA otherA) {
    return defaultValueA();
  }

  T aOtherB(A a, OtherB otherB) {
    return defaultValueA();
  }

  T bOtherA(B b, OtherA otherA) {
    return defaultValueB();
  }

  T bOtherB(B b, OtherB otherB) {
    return defaultValueB();
  }
}

abstract class _$TargetClassDispatcher<T> {
  T accept(Base base, OtherBase otherBase) {
    return _$TargetClassDispatcher.acceptFunc(
        aOtherA, aOtherB, bOtherA, bOtherB)(base, otherBase);
  }

  static T Function(Base, OtherBase) acceptFunc<T>(
      T Function(A, OtherA) aOtherA,
      T Function(A, OtherB) aOtherB,
      T Function(B, OtherA) bOtherA,
      T Function(B, OtherB) bOtherB) {
    return (baseParam, otherBaseParam) {
      if (baseParam is A && otherBaseParam is OtherA) {
        return aOtherA(baseParam, otherBaseParam);
      } else if (baseParam is A && otherBaseParam is OtherB) {
        return aOtherB(baseParam, otherBaseParam);
      } else if (baseParam is B && otherBaseParam is OtherA) {
        return bOtherA(baseParam, otherBaseParam);
      } else if (baseParam is B && otherBaseParam is OtherB) {
        return bOtherB(baseParam, otherBaseParam);
      } else {
        throw ArgumentError(
            "Unknown class given to one or all of class_switch's accept args: $baseParam, $otherBaseParam. Have you added a new sub class for any of: Base, OtherBase without running pub run build_runner build?. ");
      }
    };
  }

  T aOtherA(A a, OtherA otherA);
  T aOtherB(A a, OtherB otherB);
  T bOtherA(B b, OtherA otherA);
  T bOtherB(B b, OtherB otherB);
}
''')
@ClassSwitch(classes: [Base, OtherBase])
class TargetClass {}

abstract class Base {}

class A extends Base {}

class B extends Base {}

abstract class OtherBase {}

class OtherA extends OtherBase {}

class OtherB extends OtherBase {}
