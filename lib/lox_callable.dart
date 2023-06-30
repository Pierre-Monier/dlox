import 'interpreter.dart';

abstract interface class LoxCallable {
  Object? call(Interpreter interpreter, List<Object?> arguments);
  int arity();
}
