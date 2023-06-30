import 'expr.dart';
import 'token.dart';

abstract class Stmt {
  R accept<R>(StmtVisitor<R> visitor);
}

abstract interface class StmtVisitor<R> {
  R visitBlockStmt(Block stmt);
  R visitExpressionStmt(Expression stmt);
  R visitIfStmt(If stmt);
  R visitPrintStmt(Print stmt);
  R visitWhileStmt(While stmt);
  R visitVarStmt(Var stmt);
}

class Block extends Stmt {
  Block(this.statements);

  final List<Stmt> statements;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitBlockStmt(this);
  }
}


class Expression extends Stmt {
  Expression(this.expression);

  final Expr expression;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitExpressionStmt(this);
  }
}


class If extends Stmt {
  If(this.condition, this.thenBranch, this.elseBranch);

  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitIfStmt(this);
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


class While extends Stmt {
  While(this.condition, this.body);

  final Expr condition;
  final Stmt body;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitWhileStmt(this);
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
