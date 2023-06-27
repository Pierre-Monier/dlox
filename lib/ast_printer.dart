import 'expr.dart';
import 'token.dart';
import 'token_type.dart';

// This file is only for debugging purposes.
void main(List<String> args) {
  final expression = Binary(
    Unary(
      Token(TokenType.MINUS, '-', null, 1),
      Literal(123),
    ),
    Token(TokenType.STAR, '*', null, 1),
    Grouping(Literal(45.67)),
  );

  final result = AstPrinter().print(expression);
  print(result);
}

class AstPrinter implements ExprVisitor<String> {
  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitBinaryExpr(Binary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return _parenthesize('group', [expr.expression]);
  }

  @override
  String visitLiteralExpr(Literal expr) {
    if (expr.value == null) return 'nil';
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.right]);
  }

  _parenthesize(String name, Iterable<Expr> exprs) {
    final buffer = StringBuffer();

    buffer.write('(');
    buffer.write(name);

    for (final expr in exprs) {
      buffer.write(' ');
      buffer.write(expr.accept(this));
    }

    buffer.write(')');

    return buffer.toString();
  }

  @override
  String visitTernaryExpr(Ternary expr) {
    return _parenthesize(
        expr.condition.accept(this), [expr.thenBranch, expr.elseBranch]);
  }
}
