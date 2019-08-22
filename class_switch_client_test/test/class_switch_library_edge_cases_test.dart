import 'package:class_switch/class_switch.dart';
import 'package:test/test.dart';

part 'class_switch_library_edge_cases_test.g.dart';

// TODO This should be a generator error and not compile!
//@class_switch
//class ClassWithNoSubClasses{}

@class_switch
class NonAbstractBaseClass{}

class FirstSubClassOfNonAbstractBaseClass extends NonAbstractBaseClass{}
class SecondSubClassOfNonAbstractBaseClass extends NonAbstractBaseClass{}

@class_switch
abstract class BaseClass{}

class FirstSubType extends BaseClass {}
class SecondSubType extends BaseClass {}

class FirstSubTypeOfFirstSubType extends FirstSubType {}
class SecondSubTypeOfFirstSubType extends FirstSubType {}





void main() {
  group('Tests showing class_switch library behaviour in edge cases.', (){
    test('Generates an extra handler function for the base class type if it is not abstract.', (){
      String Function(NonAbstractBaseClass) func = NonAbstractBaseClassSwitcher.nonAbstractBaseClassSwitcher<String>(
              (firstSubType)          {return "first";},
              (secondSubType)         {return "second";},
              (nonAbstractBaseClass)  {return "base";});
      expect(func(FirstSubClassOfNonAbstractBaseClass()),   "first");
      expect(func(SecondSubClassOfNonAbstractBaseClass()),  "second");
      expect(func(NonAbstractBaseClass()),                  "base");
    });
    test('Only generates for immediate sub-classes of the annotated type and ignores any sub-classes of the sub-classes', (){
      String Function(BaseClass) func = BaseClassSwitcher.baseClassSwitcher<String>(
              (firstSubType) {return "first";},
              (secondSubType){return "second";
              });
      expect(func(FirstSubType()), "first");
      expect(func(SecondSubType()), "second");
      expect(func(FirstSubTypeOfFirstSubType()), "first");
      expect(func(SecondSubTypeOfFirstSubType()), "first");
    });
  });
}
