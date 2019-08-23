import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dispatchable_annotation/dispatchable_annotation.dart';
import 'package:dispatchable_generator/dispatchable_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/src/build_log_tracking.dart';
import 'package:source_gen_test/src/init_library_reader.dart';
import 'package:source_gen_test/src/test_annotated_classes.dart';

Future main() async {
  initializeBuildLogTracking();
  await testFile('invalid_usages_test_src.dart');
  await testFile('dispatchable_test_src.dart');
}

Future testFile(String fileName) async {
  final LibraryReader reader = await initializeLibraryReaderForDirectory(
      'test/generated_code_tests', fileName);

  testAnnotatedElements<Dispatchable>(
    reader,
    WrappingDispatchableGeneratorForTest(reader),
  );
}

class WrappingDispatchableGeneratorForTest
    extends GeneratorForAnnotation<Dispatchable> {
  final LibraryReader _libraryReader;

  WrappingDispatchableGeneratorForTest(this._libraryReader);

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return DispatchableGenerator().generateForElement(element, _libraryReader);
  }
}
