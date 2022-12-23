import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:class_switch/class_switch.dart';
import 'package:class_switch_generator/class_switch_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_test/src/build_log_tracking.dart';
import 'package:source_gen_test/src/init_library_reader.dart';
import 'package:source_gen_test/src/test_annotated_classes.dart';

Future main() async {
  initializeBuildLogTracking();
  await testFile('invalid_usages_test_src.dart');
  await testFile('class_switch_generator_test_src.dart');
  await testFile('multi_class_switch_generator_test_src.dart');
}

Future testFile(String fileName) async {
  final LibraryReader reader = await initializeLibraryReaderForDirectory(
    'test/generated_code_tests',
    fileName,
  );

  testAnnotatedElements<ClassSwitch>(
    reader,
    WrappingClassSwitchGeneratorForTest(reader),
  );
}

class WrappingClassSwitchGeneratorForTest
    extends GeneratorForAnnotation<ClassSwitch> {
  final LibraryReader _libraryReader;

  WrappingClassSwitchGeneratorForTest(this._libraryReader);

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    return ClassSwitchGenerator()
        .generateForElement(element, annotation, _libraryReader);
  }
}
