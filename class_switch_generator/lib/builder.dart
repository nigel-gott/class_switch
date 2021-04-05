import 'package:build/build.dart';
import 'package:class_switch_generator/src/class_switch_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder class_switch(BuilderOptions options) =>
    SharedPartBuilder([ClassSwitchGenerator()], 'class_switch');
