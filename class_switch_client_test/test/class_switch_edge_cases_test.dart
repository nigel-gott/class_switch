import 'package:class_switch/class_switch.dart';
import 'package:test/test.dart';

part 'class_switch_edge_cases_test.g.dart';

@ClassSwitch()
class NonAbstractBaseClass {}

class FirstSubClassOfNonAbstractBaseClass extends NonAbstractBaseClass {}

class SecondSubClassOfNonAbstractBaseClass extends NonAbstractBaseClass {}

@ClassSwitch()
abstract class BaseClass {}

class FirstSubType extends BaseClass {}

class SecondSubType extends BaseClass {}

class FirstSubTypeOfFirstSubType extends FirstSubType {}

class SecondSubTypeOfFirstSubType extends FirstSubType {}

@ClassSwitch()
class ClassWithNoSubClasses {}

void main() {
  group('Tests showing class_switch library behaviour in edge cases.', () {
    test(
        'Generates an extra handler function for the base class type if it is '
        'not abstract.', () {
      String func(NonAbstractBaseClass f) =>
          $switchNonAbstractBaseClass<String>(f)(
            (firstSubType) => 'first', //
            (secondSubType) => 'second',
            (nonAbstractBaseClass) => 'base',
          );
      expect(func(FirstSubClassOfNonAbstractBaseClass()), 'first');
      expect(func(SecondSubClassOfNonAbstractBaseClass()), 'second');
      expect(func(NonAbstractBaseClass()), 'base');
    });
    test(
        'Only generates for immediate sub-classes of the annotated type and '
        'ignores any sub-classes of the sub-classes', () {
      String func(BaseClass f) => $switchBaseClass<String>(f)(
            (firstSubType) => 'first', //
            (secondSubType) => 'second',
          );
      expect(func(FirstSubType()), 'first');
      expect(func(SecondSubType()), 'second');
      expect(func(FirstSubTypeOfFirstSubType()), 'first');
      expect(func(SecondSubTypeOfFirstSubType()), 'first');
    });
    test(
        'Generates with a single switch handler for the base class when non '
        'abstract base class with no sub classes is annotated', () {
      expect(
        $switchClassWithNoSubClasses(ClassWithNoSubClasses())(
          (classWithNoSubClasses) => 1,
        ),
        1,
      );
    });
  });
}
