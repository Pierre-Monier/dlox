import 'expr.dart';
import 'token.dart';

abstract class Stmt {
  R accept<R>(StmtVisitor<R> visitor);
}

abstract interface class StmtVisitor<R> {
  R visitBlockStmt(Block stmt);
  R visitClassStmt(Class stmt);
  R visitExpressionStmt(Expression stmt);
  R visitLFunctionStmt(LFunction stmt);
  R visitIfStmt(If stmt);
  R visitPrintStmt(Print stmt);
  R visitReturnStmt(Return stmt);
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


class Class extends Stmt {
  Class(this.name, this.superclass, this.methods);

  final Token name;
  final Variable? superclass;
  final List<LFunction> methods;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitClassStmt(this);
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


class LFunction extends Stmt {
  LFunction(this.name, this.params, this.body);

  final Token name;
  final List<Token> params;
  final List<Stmt> body;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitLFunctionStmt(this);
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


class Return extends Stmt {
  Return(this.keyword, this.value);

  final Token keyword;
  final Expr? value;

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitReturnStmt(this);
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
