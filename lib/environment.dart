import 'interpreter.dart';
import 'token.dart';

class Environment {
  final Environment? enclosing;
  final _values = <String, Object?>{};

  Environment({required Environment? enclosing}) : enclosing = enclosing;

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    if (enclosing case var enclosing?) {
      return enclosing.get(name);
    }

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  void define(String name, Object? value) {
    _values[name] = value;
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (enclosing case var enclosing?) {
      enclosing.assign(name, value);
      return;
    }

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  Object? getAt(int distance, String name) {
    return _ancestor(distance)._values[name];
  }

  Environment _ancestor(int distance) {
    var environment = this;
    for (var i = 0; i < distance; i++) {
      environment = environment.enclosing!;
    }
    return environment;
  }

  void assignAt(int distance, Token name, Object? value) {
    _ancestor(distance)._values[name.lexeme] = value;
  }
}
