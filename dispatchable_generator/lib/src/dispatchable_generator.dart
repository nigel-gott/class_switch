import 'dart:async';

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dispatchable/dispatchable.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'dispatchable_class_generator.dart';

class DispatchableGenerator extends Generator {
  static const TypeChecker _DispatchableAnnotationTypeChecker =
      TypeChecker.fromRuntime(Dispatchable);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) {
    return library
        .annotatedWith(_DispatchableAnnotationTypeChecker)
        .map((e) => generateForElement(e.element, e.annotation, library))
        .join();
  }

  @visibleForTesting
  String generateForElement(
      Element element, ConstantReader annotation, LibraryReader library) {
    var classes = annotation.read('classes').listValue;
    ClassElement classElement = _validateElement(element, false);
    var subTypes = classes.isNotEmpty
        ? _findSubTypesForAllClasses(classes, library)
        : [_findSubTypesForSingleClass(library, classElement)];
    subTypes.forEach((e) => _validateSubType(e, classes.isNotEmpty));

    DispatchableClassGenerator dispatchableCodeBuilder =
        DispatchableClassGenerator.create(
            classElement,
            subTypes,
            annotation.read('methodSeparator').stringValue,
            annotation.read('methodPrefix').stringValue);
    return [
      dispatchableCodeBuilder.generateDispatcherClass(),
      dispatchableCodeBuilder.generateDefaultDispatcherClass(),
    ].join("\n");
  }

  static List<TypeWithSubTypes> _findSubTypesForAllClasses(
      List<DartObject> classes, LibraryReader library) {
    List<TypeWithSubTypes> subTypes = [];
    for (var x in classes) {
      var typeValue = x.toTypeValue();
      ClassElement classElement = _validateAnnotationClass(typeValue);
      var subClasses = _findAllSubClassesInFileFromType(library, typeValue);
      subTypes.add(TypeWithSubTypes(classElement, subClasses));
    }
    return subTypes;
  }

  static ClassElement _validateAnnotationClass(DartType? type) {
    if (type == null) {
      throw InvalidGenerationSourceError(
        "@Dispatchable's classes parameter only supports classes.",
        todo: "Remove the null value from @Dispatchable's classes parameter.",
      );
    }
    if (type.element == null) {
      throw InvalidGenerationSourceError(
          "@Dispatchable's classes parameter only supports classes.",
          todo: "Remove ${type} from @Dispatchable's classes parameter.");
    }
    return _validateElement(type.element!, false);
  }

  static ClassElement _validateElement(Element element, bool multiClassMode) {
    if (element is! ClassElement || element.isEnum) {
      var error = multiClassMode
          ? "@Dispatchable's classes parameter only supports classes."
          : "@Dispatchable only supports classes.";
      var todo = multiClassMode
          ? "Remove ${element.name} from @Dispatchable's classes parameter."
          : "Remove @Dispatchable from ${element.name}.";
      throw InvalidGenerationSourceError(error, todo: todo, element: element);
    }
    return element;
  }

  static void _validateSubType(
      TypeWithSubTypes typeWithSubTypes, bool multiClassMode) {
    if (typeWithSubTypes.type.isAbstract && typeWithSubTypes.subTypes.isEmpty) {
      var todo = multiClassMode
          ? 'Remove ${typeWithSubTypes.type.name} from the classes list'
          : 'Remove @Dispatchable from ${typeWithSubTypes.type.name}';
      throw InvalidGenerationSourceError(
          '@Dispatchable does not support abstract classes with no sub '
          'classes.',
          todo: todo + ' or define sub classes for it.',
          element: typeWithSubTypes.type);
    }
  }

  static TypeWithSubTypes _findSubTypesForSingleClass(
      LibraryReader libraryReader, ClassElement element) {
    return TypeWithSubTypes(
        element,
        libraryReader.classes
            .where((s) => s.supertype?.element == element)
            .toList());
  }

  static List<ClassElement> _findAllSubClassesInFileFromType(
      LibraryReader libraryReader, DartType? element) {
    return libraryReader.classes
        .where((s) =>
            s.supertype != null && s.supertype.hashCode == element.hashCode)
        .toList();
  }
}
