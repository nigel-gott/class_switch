import 'package:build/build.dart';
import 'package:class_switch_generator/src/class_switch_generator.dart';
import 'package:source_gen/source_gen.dart';

// ignore: non_constant_identifier_names
Builder class_switch(BuilderOptions options) =>
    SharedPartBuilder([ClassSwitchGenerator()], 'class_switch');
