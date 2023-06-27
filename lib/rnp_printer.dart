import 'expr.dart';
import 'token.dart';
import 'token_type.dart';
// This file is only for debugging purposes.

void main(List<String> args) {
  final expression = Binary(
    Binary(
      Literal(1),
      Token(TokenType.PLUS, '+', null, 1),
      Literal(2),
    ),
    Token(TokenType.STAR, '*', null, 1),
    Binary(
      Literal(4),
      Token(TokenType.MINUS, '-', null, 1),
      Literal(3),
    ),
  );

  final result = RnpPrinter().print(expression);
  print(result);
}

class RnpPrinter implements ExprVisitor<String> {
  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  visitBinaryExpr(Binary expr) {
    return '${expr.left.accept(this)} ${expr.right.accept(this)} ${expr.operator.lexeme}';
  }

  @override
  visitGroupingExpr(Grouping expr) {
    // Not needed just want to try (1 + 2) * (4 - 3)
    throw UnimplementedError();
  }

  @override
  visitLiteralExpr(Literal expr) {
    return expr.value.toString();
  }

  @override
  visitUnaryExpr(Unary expr) {
    // Not needed just want to try (1 + 2) * (4 - 3)
    throw UnimplementedError();
  }

  @override
  String visitTernaryExpr(Ternary expr) {
    // TODO: implement visitTernaryExpr
    throw UnimplementedError();
  }
}
