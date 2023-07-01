import 'interpreter.dart';
import 'lox_class.dart';
import 'token.dart';

class LoxInstance {
  final LoxClass _klass;
  final Map<String, Object?> _fields = {};

  LoxInstance(this._klass);

  Object? get(Token name) {
    if (_fields.containsKey(name.lexeme)) {
      return _fields[name.lexeme];
    }

    final method = _klass.findMethod(name.lexeme);
    if (method != null) {
      return method.bind(this);
    }

    throw RuntimeError(name, "Undefined property '${name.lexeme}'.");
  }

  void set(Token name, Object? value) {
    _fields[name.lexeme] = value;
  }

  @override
  String toString() => '${_klass.name} instance';
}
