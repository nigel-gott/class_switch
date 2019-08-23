import 'package:dispatchable_annotation/dispatchable_annotation.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow(
  "Cannot generate a dispatchable for an abstract class with no sub classes.",
  todo:
      "Remove @dispatchable from the offending class or implement sub classes for it.",
)
@dispatchable
abstract class BaseClass {}

@ShouldThrow(
  '@dispatchable can only be used to annotate a class.',
  todo: "Remove @dispatchable annotation from the offending element.",
)
@dispatchable
int cannotAnnotateShortFormFunctions() => 0;

@ShouldThrow(
  '@dispatchable can only be used to annotate a class.',
  todo: "Remove @dispatchable annotation from the offending element.",
)
@dispatchable
enum cannotAnnotateEnums { ONE }

@ShouldThrow(
  '@dispatchable can only be used to annotate a class.',
  todo: "Remove @dispatchable annotation from the offending element.",
)
@dispatchable
int cannotAnnotateFunctions() {
  return 0;
}

@ShouldThrow(
  '@dispatchable can only be used to annotate a class.',
  todo: "Remove @dispatchable annotation from the offending element.",
)
@dispatchable
int cannotAnnotateVariables = 0;

class CannotAnnotateInsideAClass {
  @ShouldThrow(
    '@dispatchable can only be used to annotate a class.',
    todo: "Remove @dispatchable annotation from the offending element.",
  )
  @dispatchable
  int cannotAnnotateInsideAnElementInsideAClass = 0;
}
