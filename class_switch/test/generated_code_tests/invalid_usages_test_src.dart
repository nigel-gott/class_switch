import 'package:class_switch_annotation/class_switch_annotation.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
  "Cannot generate a switcher for an abstract class with no sub classes.",
  todo:
      "Remove @class_switch from the offending class or implement sub classes for it.",
)
@class_switch
abstract class BaseClass {}

@ShouldThrow(
  '@class_switch can only be used to annotate a class.',
  todo: "Remove @class_switch annotation from the offending element.",
)
@class_switch
int cannotAnnotateShortFormFunctions() => 0;

@ShouldThrow(
  '@class_switch can only be used to annotate a class.',
  todo: "Remove @class_switch annotation from the offending element.",
)
@class_switch
enum cannotAnnotateEnums { ONE }

@ShouldThrow(
  '@class_switch can only be used to annotate a class.',
  todo: "Remove @class_switch annotation from the offending element.",
)
@class_switch
int cannotAnnotateFunctions() {
  return 0;
}

@ShouldThrow(
  '@class_switch can only be used to annotate a class.',
  todo: "Remove @class_switch annotation from the offending element.",
)
@class_switch
int cannotAnnotateVariables = 0;

class CannotAnnotateInsideAClass {
  @ShouldThrow(
    '@class_switch can only be used to annotate a class.',
    todo: "Remove @class_switch annotation from the offending element.",
  )
  @class_switch
  int cannotAnnotateInsideAnElementInsideAClass = 0;
}
