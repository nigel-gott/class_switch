import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:type_handler/src/type_handler_generator.dart';

Builder typeHandler(BuilderOptions options) =>
    SharedPartBuilder([TypeHandlerGenerator()], 'type_handler');
