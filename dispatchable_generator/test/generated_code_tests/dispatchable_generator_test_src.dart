import 'package:dispatchable/dispatchable.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldGenerate(r'''
abstract class BaseClassDispatcherWithDefault<T> {
  T acceptBaseClass(BaseClass baseClassInstance) {
    return BaseClassDispatcher.baseClassDispatcher(subClassA, subClassB)(
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

abstract class BaseClassDispatcher<T> {
  T acceptBaseClass(BaseClass baseClassInstance) {
    return BaseClassDispatcher.baseClassDispatcher(subClassA, subClassB)(
        baseClassInstance);
  }

  static T Function(BaseClass) baseClassDispatcher<T>(
      T Function(SubClassA) subClassA, T Function(SubClassB) subClassB) {
    return (baseClassInstance) {
      if (baseClassInstance is SubClassA) {
        return subClassA(baseClassInstance);
      } else if (baseClassInstance is SubClassB) {
        return subClassB(baseClassInstance);
      } else {
        throw ArgumentError(
            'Unknown class given to dispatchable: $baseClassInstance. Have you added a new sub class for BaseClass without running pub run build_runner build?. ');
      }
    };
  }

  T subClassA(SubClassA subClassA);
  T subClassB(SubClassB subClassB);
}
''')
@dispatchable
abstract class BaseClass {}

class SubClassA extends BaseClass {}

class SubClassB extends BaseClass {}
