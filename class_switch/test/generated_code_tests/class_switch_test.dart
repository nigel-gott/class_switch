import 'package:class_switch_annotation/class_switch_annotation.dart';
import 'package:source_gen_test/annotations.dart';


@ShouldThrow(
  '@class_switch can only be used to annotate a class.',
  todo: "Remove @class_switch annotation from the offending element.",
)
@class_switch
int youCannotApplyClassSwitchToFunctions() => 0;