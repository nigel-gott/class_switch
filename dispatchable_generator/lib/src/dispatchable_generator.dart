import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dispatchable_annotation/dispatchable_annotation.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'dispatchable_code_generator.dart';

class DispatchableGenerator extends Generator {
  static const TypeChecker DispatchableAnnotationTypeChecker =
      TypeChecker.fromRuntime(Dispatchable);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    final List<AnnotatedElement> codeElementsAnnotatedWithDispatchable =
        library.annotatedWith(DispatchableAnnotationTypeChecker).toList();
    return codeElementsAnnotatedWithDispatchable
        .map((e) => generateForElement(e.element, library))
        .join();
  }

  @visibleForTesting
  String generateForElement(Element e, LibraryReader library) {
    DispatchableCodeBuilder dispatchableCodeBuilder = fromAnnotation(e, library);
    return [
      dispatchableCodeBuilder.generateDispatcherClass(),
      dispatchableCodeBuilder.generateDefaultDispatcherClass(),
    ].join("\n");
  }

  DispatchableCodeBuilder fromAnnotation(
      Element element, LibraryReader libraryReader) {
    validateElement(element);
    return DispatchableCodeBuilder(element, findAllSubClassesInFile(libraryReader, element));
  }

  static void validateElement(Element element) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          "@dispatchable can only be used to annotate a class.",
          todo: "Remove @dispatchable annotation from the offending element.",
          element: element);
    }
  }

  static List<ClassElement> findAllSubClassesInFile(
      LibraryReader libraryReader, ClassElement element) {
    return libraryReader.classes
        .where((s) => s.supertype.element == element)
        .toList();
  }
}


