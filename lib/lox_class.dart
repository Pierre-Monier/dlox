import 'interpreter.dart';
import 'lox_callable.dart';
import 'lox_function.dart';
import 'lox_instance.dart';

class LoxClass implements LoxCallable {
  final String name;
  final Map<String, LoxFunction> _methods;

  LoxClass(this.name, this._methods);

  LoxFunction? findMethod(String name) {
    return _methods[name];
  }

  @override
  int arity() {
    final initializer = findMethod('init');
    if (initializer != null) {
      return initializer.arity();
    }

    return 0;
  }

  @override
  LoxInstance call(Interpreter interpreter, List<Object?> arguments) {
    final instance = LoxInstance(this);
    final initializer = findMethod('init');
    if (initializer != null) {
      initializer.bind(instance).call(interpreter, arguments);
    }

    return instance;
  }

  @override
  String toString() => name;
}
