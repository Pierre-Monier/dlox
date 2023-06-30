import 'token.dart';

abstract class Expr {
  R accept<R>(ExprVisitor<R> visitor);
}

abstract interface class ExprVisitor<R> {
  R visitTernaryExpr(Ternary expr);
  R visitAssignExpr(Assign expr);
  R visitBinaryExpr(Binary expr);
  R visitCallExpr(Call expr);
  R visitGroupingExpr(Grouping expr);
  R visitLiteralExpr(Literal expr);
  R visitLogicalExpr(Logical expr);
  R visitUnaryExpr(Unary expr);
  R visitVariableExpr(Variable expr);
}

class Ternary extends Expr {
  Ternary(this.condition, this.thenBranch, this.elseBranch);

  final Expr condition;
  final Expr thenBranch;
  final Expr elseBranch;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitTernaryExpr(this);
  }
}


class Assign extends Expr {
  Assign(this.name, this.value);

  final Token name;
  final Expr value;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitAssignExpr(this);
  }
}


class Binary extends Expr {
  Binary(this.left, this.operator, this.right);

  final Expr left;
  final Token operator;
  final Expr right;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}


class Call extends Expr {
  Call(this.callee, this.paren, this.arguments);

  final Expr callee;
  final Token paren;
  final List<Expr> arguments;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitCallExpr(this);
  }
}


class Grouping extends Expr {
  Grouping(this.expression);

  final Expr expression;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}


class Literal extends Expr {
  Literal(this.value);

  final Object? value;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}


class Logical extends Expr {
  Logical(this.left, this.operator, this.right);

  final Expr left;
  final Token operator;
  final Expr right;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitLogicalExpr(this);
  }
}


class Unary extends Expr {
  Unary(this.operator, this.right);

  final Token operator;
  final Expr right;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}


class Variable extends Expr {
  Variable(this.name);

  final Token name;

  @override
  R accept<R>(ExprVisitor<R> visitor) {
    return visitor.visitVariableExpr(this);
  }
}
