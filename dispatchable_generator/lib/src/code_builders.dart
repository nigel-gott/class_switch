
import 'package:optional/optional.dart';

class ClassBuilder {
  final String _className;
  final List<MethodBuilder> _methods = [];

  ClassBuilder(this._className);

  String build() {
    return """
    abstract class $_className<T> {
    ${_methods.map((f) => f.build()).join("\n")}
    }
    """;
  }

  MethodBuilder addMethod(String methodName) {
    MethodBuilder builder = MethodBuilder(methodName);
    _methods.add(builder);
    return builder;
  }
}

class MethodBuilder {
  final String _methodName;
  final List<String> _parameters = [];
  bool _static = false;
  Optional<String> _templateArgumentName = Optional.empty();
  bool _abstract = false;
  String _returnType = "void";
  String _body = "";

  MethodBuilder(this._methodName);

  String build() {
    String typeParameter = _templateArgumentName.map((t) => "<$t>").orElse("");
    String methodWithoutBody =
        "${_static ? "static" : ""} $_returnType $_methodName${typeParameter}(${_parameters.join(",")})";
    if (_abstract) {
      return methodWithoutBody + ";";
    } else {
      return """$methodWithoutBody {
$_body
}""";
    }
  }

  void whichIsAbstract() {
    _abstract = true;
  }

  void andReturns(String returnType) {
    _returnType = returnType;
  }

  void whichHasATemplateParameter(String _templateArgument) {
    _templateArgumentName = Optional.of(_templateArgument);
  }

  void withParameters(Iterable<String> parameters) {
    _parameters.addAll(parameters);
  }

  void withBody(String body) {
    _body = body;
  }

  void whichIsStatic() {
    _static = true;
  }

  void withParameter(String parameter) {
    _parameters.add(parameter);
  }

  void whichIsAbstractIf(bool abstract) {
    _abstract = abstract;
  }
}