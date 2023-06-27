import 'expr.dart';
import 'token.dart';

abstract class Stmt {
  R accept<R>(StmtVisitor<R> visitor);
}

abstract interface class StmtVisitor<R> {
  R visitExpressionStmt(Expression stmt);
  R visitPrintStmt(Print stmt);
  R visitVarStmt(Var stmt);
}

class Expression extends Stmt {
  Expression(this.expression);

  final Expr expression;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}


class Print extends Stmt {
  Print(this.expression);

  final Expr expression;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitPrintStmt(this);
  }
}


class Var extends Stmt {
  Var(this.name, this.initializer);

  final Token name;
  final Expr? initializer;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitVarStmt(this);
  }
}