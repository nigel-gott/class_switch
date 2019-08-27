import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dispatchable_annotation/dispatchable_annotation.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'dispatchable_class_generator.dart';

class DispatchableGenerator extends Generator {
  static const TypeChecker _DispatchableAnnotationTypeChecker =
      TypeChecker.fromRuntime(Dispatchable);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return library.annotatedWith(_DispatchableAnnotationTypeChecker)
        .map((e) => generateForElement(e.element, library))
        .join();
  }

  @visibleForTesting
  String generateForElement(Element element, LibraryReader library) {
    _validateElement(element);
    List<ClassElement> subClasses = DispatchableGenerator._findAllSubClassesInFile(library, element);
    DispatchableClassGenerator dispatchableCodeBuilder = DispatchableClassGenerator.validateAndCreate(element, subClasses);
    return [
      dispatchableCodeBuilder.generateDispatcherClass(),
      dispatchableCodeBuilder.generateDefaultDispatcherClass(),
    ].join("\n");
  }

  static void _validateElement(Element element) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          "@dispatchable can only be used to annotate a class.",
          todo: "Remove @dispatchable annotation from the offending element.",
          element: element);
    }
  }

  static List<ClassElement> _findAllSubClassesInFile(
      LibraryReader libraryReader, ClassElement element) {
    return libraryReader.classes
        .where((s) => s.supertype.element == element)
        .toList();
  }
}


