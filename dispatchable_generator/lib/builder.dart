import 'package:build/build.dart';
import 'package:dispatchable_generator/src/dispatchable_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder typeHandler(BuilderOptions options) =>
    SharedPartBuilder([DispatchableGenerator()], 'dispatchable');