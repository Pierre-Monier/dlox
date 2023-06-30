import 'interpreter.dart';
import 'lox_callable.dart';

class LoxClock implements LoxCallable {
  @override
  int arity() {
    return 0;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return DateTime.now().millisecondsSinceEpoch / 1000;
  }

  @override
  String toString() {
    return '<native fn>';
  }
}
