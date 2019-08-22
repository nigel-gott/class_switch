import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:class_switch/class_switch.dart';
import 'package:class_switch_annotation/class_switch_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'package:source_gen_test/src/build_log_tracking.dart';
import 'package:source_gen_test/src/init_library_reader.dart';
import 'package:source_gen_test/src/test_annotated_classes.dart';


Future main() async {
  initializeBuildLogTracking();
  final reader = await initializeLibraryReaderForDirectory(
      'test/generated_code_tests', 'class_switch_test.dart');

  testAnnotatedElements<ClassSwitch>(
    reader,
    WrappingClassSwitchGeneratorForTest(reader),
  );
}

class WrappingClassSwitchGeneratorForTest extends GeneratorForAnnotation<ClassSwitch>{
  final LibraryReader _libraryReader;

  WrappingClassSwitchGeneratorForTest(this._libraryReader);
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    return ClassSwitchGenerator().generateForElement(element, _libraryReader);
  }
}
