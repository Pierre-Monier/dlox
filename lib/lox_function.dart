import 'environment.dart';
import 'interpreter.dart';
import 'lox_callable.dart';
import 'lox_instance.dart';
import 'stmt.dart';

class LoxFunction implements LoxCallable {
  final LFunction _declaration;
  LoxFunction(this._declaration, this._closure, this._isInitializer);
  final Environment _closure;
  final bool _isInitializer;

  LoxFunction bind(LoxInstance instance) {
    final environment = Environment(enclosing: _closure);
    environment.define('this', instance);
    return LoxFunction(_declaration, environment, _isInitializer);
  }

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
      if (_isInitializer) return _closure.getAt(0, 'this');
      return e.value;
    }

    // We use getAt(0, ...) to make sure to find this in the current scope
    if (_isInitializer) return _closure.getAt(0, 'this');

    return null;
  }

  @override
  String toString() {
    return '<fn ${_declaration.name.lexeme}>';
  }
}
