import 'package:class_switch/class_switch.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
  '@ClassSwitch does not support abstract classes with no sub '
  'classes.',
  todo: 'Remove @ClassSwitch from BaseClass or define sub classes for it.',
)
@ClassSwitch()
abstract class BaseClass {}

@ShouldThrow(
  '@ClassSwitch only supports classes.',
  todo: 'Remove @ClassSwitch from cannotAnnotateShortFormFunctions.',
)
@ClassSwitch()
int cannotAnnotateShortFormFunctions() => 0;

@ShouldThrow(
  '@ClassSwitch only supports classes.',
  todo: 'Remove @ClassSwitch from CannotAnnotateEnums.',
)
@ClassSwitch()
enum CannotAnnotateEnums { one }

@ShouldThrow(
  '@ClassSwitch only supports classes.',
  todo: 'Remove @ClassSwitch from cannotAnnotateFunctions.',
)
@ClassSwitch()
int cannotAnnotateFunctions() {
  return 0;
}

@ShouldThrow(
  '@ClassSwitch only supports classes.',
  todo: 'Remove @ClassSwitch from cannotAnnotateVariables.',
)
@ClassSwitch()
int cannotAnnotateVariables = 0;

class CannotAnnotateInsideAClass {
  @ShouldThrow(
    '@ClassSwitch only supports classes.',
    todo: 'Remove @ClassSwitch from cannotAnnotateInsideAnElementInsideAClass.',
  )
  @ClassSwitch()
  int cannotAnnotateInsideAnElementInsideAClass = 0;
}
