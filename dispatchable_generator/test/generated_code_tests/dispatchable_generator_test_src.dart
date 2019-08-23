import 'package:dispatchable_annotation/dispatchable_annotation.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
abstract class BaseDispatchableerWithDefault<T> {
  T acceptBaseClass(BaseClass baseClassInstance) {
    return BaseDispatchableer.baseDispatchableer(subClassA, subClassB)(
        baseClassInstance);
  }

  T defaultValue();

  T subClassA(SubClassA subClassA) {
    return defaultValue();
  }

  T subClassB(SubClassB subClassB) {
    return defaultValue();
  }
}

abstract class BaseDispatchableer<T> {
  static T Function(BaseClass) baseDispatchableer<T>(
      T Function(SubClassA) subClassA, T Function(SubClassB) subClassB) {
    return (baseClassInstance) {
      if (baseClassInstance is SubClassA) {
        return subClassA(baseClassInstance);
      } else if (baseClassInstance is SubClassB) {
        return subClassB(baseClassInstance);
      } else if (baseClassInstance == null) {
        throw ArgumentError("Null parameter passed to dispatchable.");
      } else {
        throw ArgumentError(
            "Unknown class given to dispatchable: $baseClassInstance. Have you added a new sub class for BaseClass without running pub run build_runner build?. ");
      }
    };
  }

  T acceptBaseClass(BaseClass baseClassInstance) {
    return baseDispatchableer(subClassA, subClassB)(baseClassInstance);
  }

  T subClassA(SubClassA subClassA);
  T subClassB(SubClassB subClassB);
}
''')
@dispatchable
abstract class BaseClass {}

class SubClassA extends BaseClass {}

class SubClassB extends BaseClass {}
