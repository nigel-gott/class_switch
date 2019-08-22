import 'package:build/build.dart';
import 'package:class_switch/src/class_switch_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder typeHandler(BuilderOptions options) =>
    SharedPartBuilder([ClassSwitchGenerator()], 'class_switch');
