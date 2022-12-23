import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:class_switch/class_switch.dart';
import 'package:class_switch_generator/src/class_switch_class_generator.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

class ClassSwitchGenerator extends Generator {
  static const TypeChecker _classSwitchAnnotationTypeChecker =
      TypeChecker.fromRuntime(ClassSwitch);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return library
        .annotatedWith(_classSwitchAnnotationTypeChecker)
        .map((e) => generateForElement(e.element, e.annotation, library))
        .join();
  }

  @visibleForTesting
  String generateForElement(
    Element element,
    ConstantReader annotation,
    LibraryReader library,
  ) {
    final classes = annotation.read('classes').listValue;
    final ClassElement classElement = _validateElement(element, false);
    final subTypes = classes.isNotEmpty
        ? _findSubTypesForAllClasses(classes, library)
        : [_findSubTypesForSingleClass(library, classElement)];
    for (final e in subTypes) {
      _validateSubType(e, classes.isNotEmpty);
    }

    final optionsReader = annotation.read('options');

    final ClassSwitchOptions generatorOptions =
        extractOptionsFromAnnotation(optionsReader);

    final ClassSwitchClassGenerator classSwitchCodeBuilder =
        ClassSwitchClassGenerator.create(
      classElement,
      subTypes,
      generatorOptions,
    );
    return classSwitchCodeBuilder.generateAll();
  }

  ClassSwitchOptions extractOptionsFromAnnotation(
    ConstantReader optionsReader,
  ) {
    return ClassSwitchOptions(
      switchFunctionPrefix:
          optionsReader.read('switchFunctionPrefix').stringValue,
      abstractMethodSubTypeSeparator:
          optionsReader.read('abstractMethodSubTypeSeparator').stringValue,
      abstractMethodPrefix:
          optionsReader.read('abstractMethodPrefix').stringValue,
      dslMode: getDslMode(optionsReader),
    );
  }

  DSL_MODE getDslMode(ConstantReader optionsReader) {
    final dartObject = optionsReader.read('dslMode').objectValue;
    final enumIndex = dartObject.getField('index')!.toIntValue();
    return DSL_MODE.values[enumIndex!];
  }

  static List<TypeWithSubTypes> _findSubTypesForAllClasses(
    List<DartObject> classes,
    LibraryReader library,
  ) {
    final List<TypeWithSubTypes> subTypes = [];
    for (final x in classes) {
      final typeValue = x.toTypeValue();
      final ClassElement classElement = _validateAnnotationClass(typeValue);
      final subClasses = _findAllSubClassesInFileFromType(library, typeValue);
      subTypes.add(TypeWithSubTypes(classElement, subClasses));
    }
    return subTypes;
  }

  static ClassElement _validateAnnotationClass(DartType? type) {
    if (type == null) {
      throw InvalidGenerationSourceError(
        "@ClassSwitch's classes parameter only supports classes.",
        todo: "Remove the null value from @ClassSwitch's classes parameter.",
      );
    }
    if (type.element == null) {
      throw InvalidGenerationSourceError(
        "@ClassSwitch's classes parameter only supports classes.",
        todo: "Remove $type from @ClassSwitch's classes parameter.",
      );
    }
    return _validateElement(type.element!, false);
  }

  static ClassElement _validateElement(Element element, bool multiClassMode) {
    if (element is! ClassElement || element is EnumElement) {
      final error = multiClassMode
          ? "@ClassSwitch's classes parameter only supports classes."
          : "@ClassSwitch only supports classes.";
      final todo = multiClassMode
          ? "Remove ${element.name} from @ClassSwitch's classes parameter."
          : "Remove @ClassSwitch from ${element.name}.";
      throw InvalidGenerationSourceError(error, todo: todo, element: element);
    }
    return element;
  }

  static void _validateSubType(
    TypeWithSubTypes typeWithSubTypes,
    bool multiClassMode,
  ) {
    if (typeWithSubTypes.type.isAbstract && typeWithSubTypes.subTypes.isEmpty) {
      final todo = multiClassMode
          ? 'Remove ${typeWithSubTypes.type.name} from the classes list'
          : 'Remove @ClassSwitch from ${typeWithSubTypes.type.name}';
      throw InvalidGenerationSourceError(
        '@ClassSwitch does not support abstract classes with no sub '
        'classes.',
        todo: '$todo or define sub classes for it.',
        element: typeWithSubTypes.type,
      );
    }
  }

  static TypeWithSubTypes _findSubTypesForSingleClass(
    LibraryReader libraryReader,
    ClassElement element,
  ) {
    return TypeWithSubTypes(
      element,
      libraryReader.classes
          .where((s) => s.supertype?.element == element)
          .toList(),
    );
  }

  static List<ClassElement> _findAllSubClassesInFileFromType(
    LibraryReader libraryReader,
    DartType? element,
  ) {
    return libraryReader.classes
        .where(
          (s) =>
              s.supertype != null && s.supertype.hashCode == element.hashCode,
        )
        .toList();
  }
}
