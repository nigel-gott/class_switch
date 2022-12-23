// ignore_for_file: avoid_positional_boolean_parameters

import 'package:optional/optional.dart';

class TypeAndName {
  final String type;
  final String name;

  TypeAndName(this.type, this.name);
}

class ClassBuilder {
  final String _className;
  final List<String> _genericTypes = [];
  final List<String> _attributes = [];
  final List<MethodBuilder> _methods = [];
  bool _abstract = false;

  ClassBuilder(this._className);

  String build() {
    return """
    ${_abstract ? 'abstract' : ''} class $_className${_genericTypes.isNotEmpty ? '<${_genericTypes.join(',')}>' : ''} {
    ${_attributes.join("\n")}
    ${_methods.map((f) => f.build()).join("\n")}
    }
    """;
  }

  void whichIsAbstract() {
    _abstract = true;
  }

  void whichHasATemplateParameter(String param) {
    _genericTypes.add(param);
  }

  void addAttribute(bool isFinal, String type, String name) {
    _attributes.add('${isFinal ? 'final ' : ''} $type $name;');
  }

  void addConstructorWithFinalAttributes(List<TypeAndName> attributes) {
    for (final e in attributes) {
      addAttribute(true, e.type, e.name);
    }
    addMethod(_className)
      ..withParameters(attributes.map((e) => 'this.${e.name}'))
      ..whichIsAbstract()
      ..andReturns('');
  }

  MethodBuilder addMethod(String methodName) {
    final MethodBuilder builder = MethodBuilder(methodName);
    _methods.add(builder);
    return builder;
  }
}

class ExtensionBuilder {
  final String _on;
  final String _name;
  final List<MethodBuilder> _methods = [];

  ExtensionBuilder(this._on, this._name);

  MethodBuilder addMethod(String methodName) {
    final MethodBuilder builder = MethodBuilder(methodName);
    _methods.add(builder);
    return builder;
  }

  String build() {
    return """
    extension $_name on $_on {
      ${_methods.map((f) => f.build()).join("\n")}
    }
    """;
  }
}

class MethodBuilder {
  final String _methodName;
  final List<String> _parameters = [];
  bool _static = false;
  Optional<String> _templateArgumentName = const Optional.empty();
  bool _abstract = false;
  String _returnType = "void";
  String _body = "";

  MethodBuilder(this._methodName);

  String build() {
    final String typeParameter =
        _templateArgumentName.map((t) => "<$t>").orElse("");
    final String methodWithoutBody =
        "${_static ? "static" : ""} $_returnType $_methodName$typeParameter(${_parameters.join(",")})";
    if (_abstract) {
      return "$methodWithoutBody;";
    } else {
      return """
$methodWithoutBody {
$_body
}""";
    }
  }

  void whichIsAbstract() {
    _abstract = true;
  }

  // ignore: use_setters_to_change_properties
  void andReturns(String returnType) {
    _returnType = returnType;
  }

  void whichHasATemplateParameter(String templateArgument) {
    _templateArgumentName = Optional.of(templateArgument);
  }

  void withParameters(Iterable<String> parameters) {
    _parameters.addAll(parameters);
  }

  // ignore: use_setters_to_change_properties
  void withBody(String body) {
    _body = body;
  }

  void whichIsStatic() {
    _static = true;
  }

  void withParameter(String parameter) {
    _parameters.add(parameter);
  }

  // ignore: use_setters_to_change_properties
  void whichIsAbstractIf(bool abstract) {
    _abstract = abstract;
  }
}
