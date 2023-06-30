import 'environment.dart';
import 'interpreter.dart';
import 'lox_callable.dart';
import 'stmt.dart';

class LoxFunction implements LoxCallable {
  final LFunction _declaration;
  LoxFunction(this._declaration, this._closure);
  final Environment _closure;

  @override
  int arity() {
    return _declaration.params.length;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    final environment = Environment(enclosing: _closure);
    for (var i = 0; i < _declaration.params.length; i++) {
      // We set every arguments of the function in scope to make them available
      environment.define(_declaration.params[i].lexeme, arguments[i]);
    }

    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on ReturnException catch (e) {
      return e.value;
    }

    return null;
  }

  @override
  String toString() {
    return '<fn ${_declaration.name.lexeme}>';
  }
}
