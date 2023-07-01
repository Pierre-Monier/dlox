import 'expr.dart';
import 'interpreter.dart';
import 'lox.dart';
import 'stmt.dart';
import 'token.dart';

class Resolver implements ExprVisitor, StmtVisitor {
  final List<Map<String, bool>> _scopes = [];
  final Interpreter _interpreter;
  FunctionType _currentFunction = FunctionType.NONE;
  ClassType _currentClass = ClassType.NONE;

  Resolver(this._interpreter);

  @override
  visitBlockStmt(Block stmt) {
    _beginScope();
    resolves(stmt.statements);
    _endScope();
  }

  @override
  visitLFunctionStmt(LFunction stmt) {
    _declare(stmt.name);
    _define(stmt.name);

    _resolveFunction(stmt, FunctionType.FUNCTION);
  }

  @override
  visitVarStmt(Var stmt) {
    _declare(stmt.name);
    if (stmt.initializer case var initializer?) {
      _resolveExpr(initializer);
    }
    _define(stmt.name);
  }

  void resolves(List<Stmt> statements) {
    for (var statement in statements) {
      _resolveStmt(statement);
    }
  }

  void _resolveStmt(Stmt statement) {
    statement.accept(this);
  }

  void _resolveExpr(Expr expr) {
    expr.accept(this);
  }

  void _resolveFunction(LFunction function, FunctionType type) {
    final enclosingFunction = _currentFunction;
    _currentFunction = FunctionType.FUNCTION;

    _beginScope();
    for (var param in function.params) {
      _declare(param);
      _define(param);
    }
    resolves(function.body);
    _endScope();

    _currentFunction = enclosingFunction;
  }

  void _beginScope() {
    _scopes.add({});
  }

  void _endScope() {
    _scopes.removeLast();
  }

  _declare(Token name) {
    if (_scopes.isEmpty) return;

    var scope = _scopes.last;
    if (scope.containsKey(name.lexeme)) {
      Lox.errorWithToken(
          name, 'Variable with this name already declared in this scope.');
    }

    scope.addAll({name.lexeme: false});
  }

  _define(Token name) {
    if (_scopes.isEmpty) return;

    var scope = _scopes.last;
    scope[name.lexeme] = true;
  }

  @override
  visitVariableExpr(Variable expr) {
    if (_scopes.isNotEmpty && _scopes.last[expr.name.lexeme] == false) {
      throw Exception('Cannot read local variable in its own initializer.');
    }

    _resolveLocal(expr, expr.name);
  }

  @override
  visitAssignExpr(Assign expr) {
    _resolveExpr(expr.value);
    _resolveLocal(expr, expr.name);
  }

  _resolveLocal(Expr expr, Token name) {
    for (var i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(name.lexeme)) {
        _interpreter.resolve(expr, _scopes.length - 1 - i);
      }
    }
  }

  @override
  visitBinaryExpr(Binary expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  visitCallExpr(Call expr) {
    _resolveExpr(expr.callee);
    for (var argument in expr.arguments) {
      _resolveExpr(argument);
    }
  }

  @override
  visitExpressionStmt(Expression stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  visitGroupingExpr(Grouping expr) {
    _resolveExpr(expr.expression);
  }

  @override
  visitIfStmt(If stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.thenBranch);
    if (stmt.elseBranch case var elseBranch?) _resolveStmt(elseBranch);
  }

  @override
  visitLiteralExpr(Literal expr) {
    return null;
  }

  @override
  visitLogicalExpr(Logical expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  visitPrintStmt(Print stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  visitReturnStmt(Return stmt) {
    if (_currentFunction == FunctionType.NONE) {
      Lox.errorWithToken(stmt.keyword, 'Cannot return from top-level code.');
    }

    if (stmt.value case var value?) {
      if (_currentFunction == FunctionType.INITIALIZER) {
        Lox.errorWithToken(
            stmt.keyword, 'Cannot return a value from an initializer.');
      }

      _resolveExpr(value);
    }
  }

  @override
  visitTernaryExpr(Ternary expr) {
    _resolveExpr(expr.condition);
    _resolveExpr(expr.thenBranch);
    _resolveExpr(expr.elseBranch);
  }

  @override
  visitUnaryExpr(Unary expr) {
    _resolveExpr(expr.right);
  }

  @override
  visitWhileStmt(While stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.body);
  }

  @override
  visitClassStmt(Class stmt) {
    final enclosingClass = _currentClass;
    _currentClass = ClassType.CLASS;

    _declare(stmt.name);
    _define(stmt.name);

    _beginScope();
    _scopes.last.addAll({'this': true});

    for (final method in stmt.methods) {
      final declaration = method.name.lexeme == 'init'
          ? FunctionType.INITIALIZER
          : FunctionType.METHOD;

      _resolveFunction(method, declaration);
    }

    _endScope();

    _currentClass = enclosingClass;
  }

  @override
  visitGetExpr(Get expr) {
    _resolveExpr(expr.object);
  }

  @override
  visitSetExpr(Set expr) {
    _resolveExpr(expr.value);
    _resolveExpr(expr.object);
  }

  @override
  visitThisExpr(This expr) {
    if (_currentClass == ClassType.NONE) {
      Lox.errorWithToken(
          expr.keyword, 'Cannot use \'this\' outside of a class.');
      return;
    }

    _resolveLocal(expr, expr.keyword);
  }
}

enum FunctionType {
  NONE,
  FUNCTION,
  METHOD,
  INITIALIZER,
}

enum ClassType {
  NONE,
  CLASS,
}
