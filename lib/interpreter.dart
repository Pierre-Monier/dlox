import 'environment.dart';
import 'expr.dart';
import 'lox.dart';
import 'stmt.dart';
import 'token.dart';
import 'token_type.dart';

class Interpreter implements ExprVisitor<Object?>, StmtVisitor<void> {
  static const _notNumberOrStringErrorMessage =
      'Operands must be two numbers or two strings.';

  final _environment = Environment();

  void interpret(List<Stmt> statements) {
    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } on RuntimeError catch (e) {
      Lox.runtimeError(e);
    }
  }

  @override
  Object? visitBinaryExpr(Binary expr) {
    final left = _evaluate(expr.left);
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.MINUS:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) - (right as num);
      case TokenType.PLUS:
        if (left is num && right is num) {
          return left + right;
        } else if (left is String || right is String) {
          return '${left is int ? left.toInt() : left}${right is int ? right.toInt() : 'right'}';
        }

        throw RuntimeError(expr.operator, _notNumberOrStringErrorMessage);
      case TokenType.SLASH:
        _checkNumberOperands(expr.operator, left, right);
        if (right == 0) {
          throw DivisionByZeroError(expr.operator);
        }
        return (left as num) / (right as num);
      case TokenType.STAR:
        _checkNumberOperands(expr.operator, left, right);
        return (left as num) * (right as num);
      case TokenType.GREATER:
        if (left is String && right is String) {
          return left.compareTo(right) > 0;
        } else if (left is num && right is num) {
          return left > right;
        }

        throw RuntimeError(expr.operator, _notNumberOrStringErrorMessage);
      case TokenType.GREATER_EQUAL:
        if (left is String && right is String) {
          return left.compareTo(right) >= 0;
        } else if (left is num && right is num) {
          return left >= right;
        }

        throw RuntimeError(expr.operator, _notNumberOrStringErrorMessage);
      case TokenType.LESS:
        if (left is String && right is String) {
          return left.compareTo(right) < 0;
        } else if (left is num && right is num) {
          return left < right;
        }

        throw RuntimeError(expr.operator, _notNumberOrStringErrorMessage);
      case TokenType.LESS_EQUAL:
        if (left is String && right is String) {
          return left.compareTo(right) <= 0;
        } else if (left is num && right is num) {
          return left <= right;
        }

        throw RuntimeError(expr.operator, _notNumberOrStringErrorMessage);
      case TokenType.BANG_EQUAL:
        return !_isEqual(left, right);
      case TokenType.EQUAL_EQUAL:
        return _isEqual(left, right);
      default:
        return null;
    }
  }

  @override
  Object? visitGroupingExpr(Grouping expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitUnaryExpr(Unary expr) {
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TokenType.BANG:
        return !_isTruthy(right);
      case TokenType.MINUS:
        _checkNumberOperand(expr.operator, right);
        return -(right as num);
      default:
        return null;
    }
  }

  Object? _evaluate(Expr expr) {
    return expr.accept(this);
  }

  void _execute(Stmt stmt) {
    stmt.accept(this);
  }

  bool _isTruthy(Object? object) {
    // Since we have a dynamically type language, we can't just break the code
    // when we have a type that must be considered as a boolean, instead we have
    // to define, what is considered as a true or a false value.
    // In Lox, only false and nil are falsey, everything else is truthy.
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  bool _isEqual(Object? a, Object? b) {
    // nil is only equal to nil.
    if (a == null && b == null) return true;
    if (a == null) return false;

    return a == b;
  }

  void _checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is num && right is num) return;
    throw RuntimeError(operator, 'Operands must be a number.');
  }

  void _checkNumberOperand(Token operator, Object? operand) {
    if (operand is num) return;
    throw RuntimeError(operator, 'Operand must be a number.');
  }

  String _stringify(Object? object) {
    if (object == null) return 'nil';

    // Hack. Work around Dart adding ".0" to integer-valued doubles.
    if (object is double) {
      var text = object.toString();
      if (text.endsWith('.0')) {
        text = text.substring(0, text.length - 2);
      }
      return text;
    }

    return object.toString();
  }

  @override
  Object? visitTernaryExpr(Ternary expr) {
    final condition = _evaluate(expr.condition);
    if (_isTruthy(condition)) {
      return _evaluate(expr.thenBranch);
    } else {
      return _evaluate(expr.elseBranch);
    }
  }

  @override
  void visitExpressionStmt(Expression stmt) {
    _evaluate(stmt.expression);
  }

  @override
  void visitPrintStmt(Print stmt) {
    final value = _evaluate(stmt.expression);
    print(_stringify(value));
  }

  @override
  void visitVarStmt(Var stmt) {
    Object? value;
    if (stmt.initializer != null) {
      value = _evaluate(stmt.initializer!);
    }

    _environment.define(stmt.name.lexeme, value);
  }

  @override
  Object? visitVariableExpr(Variable expr) {
    return _environment.get(expr.name);
  }
}

class RuntimeError implements Exception {
  final Token token;
  final String message;

  RuntimeError(this.token, this.message);

  @override
  String toString() {
    return 'RuntimeError{token: $token, message: $message}';
  }
}

class DivisionByZeroError extends RuntimeError {
  DivisionByZeroError(Token token) : super(token, 'Division by zero.');
}
