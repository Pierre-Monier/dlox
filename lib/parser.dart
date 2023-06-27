import 'expr.dart';
import 'lox.dart';
import 'stmt.dart';
import 'token.dart';
import 'token_type.dart';

class Parser {
  Parser(this._tokens);

  final List<Token> _tokens;
  int _current = 0;

  List<Stmt>? parse() {
    try {
      final statements = <Stmt>[];

      while (!_isAtEnd()) {
        final statement = _declaration();

        if (statement != null) {
          statements.add(statement);
        }
      }

      return statements;
    } on ParseError {
      return null;
    }
  }

  Stmt? _declaration() {
    try {
      if (_match([TokenType.VAR])) {
        return _varDeclaration();
      }

      return _statement();
    } on ParseError {
      _synchronize();
      return null;
    }
  }

  Stmt _varDeclaration() {
    final name = _consume(TokenType.IDENTIFIER, "Expect variable name.");

    Expr? initializer;
    if (_match([TokenType.EQUAL])) {
      initializer = _expression();
    }

    _consume(TokenType.SEMICOLON, "Expect ';' after variable declaration.");
    return Var(name, initializer);
  }

  Stmt _statement() {
    if (_match([TokenType.PRINT])) {
      return _printStatement();
    }

    return _expressionStatement();
  }

  Stmt _printStatement() {
    final value = _expression();
    _consume(TokenType.SEMICOLON, "Expect ';' after value.");
    return Print(value);
  }

  Stmt _expressionStatement() {
    final expr = _expression();
    _consume(TokenType.SEMICOLON, "Expect ';' after expression.");
    return Expression(expr);
  }

  Expr _expression() {
    return _comma();
  }

  Expr _comma() {
    var expr = _ternary();

    while (_match([TokenType.COMMA])) {
      final operator = _previous();
      final right = _ternary();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _ternary() {
    Expr? expr;
    final condition = _equality();
    Expr thenBranch = Literal(null);
    Expr elseBranch = Literal(null);

    while (_match([TokenType.QUESTION_MARK])) {
      thenBranch = _ternary();
      expr = Ternary(condition, thenBranch, elseBranch);

      _consume(TokenType.COLON, "Expect ':' after expression.");

      elseBranch = _ternary();
      expr = Ternary(condition, thenBranch, elseBranch);
    }

    return expr ?? condition;
  }

  Expr _equality() {
    var expr = _comparison();

    while (_match([TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL])) {
      final operator = _previous();
      final right = _comparison();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _comparison() {
    var expr = _term();

    while (_match([
      TokenType.GREATER,
      TokenType.GREATER_EQUAL,
      TokenType.LESS,
      TokenType.LESS_EQUAL
    ])) {
      final operator = _previous();
      final right = _term();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _term() {
    var expr = _factor();

    while (_match([TokenType.MINUS, TokenType.PLUS])) {
      final operator = _previous();
      final right = _factor();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _factor() {
    var expr = _unary();

    while (_match([TokenType.SLASH, TokenType.STAR])) {
      final operator = _previous();
      final right = _unary();
      expr = Binary(expr, operator, right);
    }

    return expr;
  }

  Expr _unary() {
    if (_match([TokenType.BANG, TokenType.MINUS])) {
      final operator = _previous();
      final right = _unary();
      return Unary(operator, right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TokenType.FALSE])) return Literal(false);
    if (_match([TokenType.TRUE])) return Literal(true);
    if (_match([TokenType.NIL])) return Literal(null);

    if (_match([TokenType.NUMBER, TokenType.STRING])) {
      return Literal(_previous().literal);
    }

    if (_match([TokenType.IDENTIFIER])) {
      return Variable(_previous());
    }

    if (_match([TokenType.LEFT_PAREN])) {
      final expr = _expression();
      _consume(TokenType.RIGHT_PAREN, "Expect ')' after expression.");
      return Grouping(expr);
    }

    throw _error(_peek(), "Expect expression.");
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();

    throw _error(_peek(), message);
  }

  ParseError _error(Token token, String message) {
    Lox.errorWithToken(token, message);
    return ParseError();
  }

  void _synchronize() {
    // We discard tokens until we find a statement boundary.
    _advance();

    while (!_isAtEnd()) {
      if (_previous().type == TokenType.SEMICOLON) return;

      switch (_peek().type) {
        case TokenType.CLASS:
        case TokenType.FUN:
        case TokenType.VAR:
        case TokenType.FOR:
        case TokenType.IF:
        case TokenType.WHILE:
        case TokenType.PRINT:
        case TokenType.RETURN:
          return;
        default:
          _advance();
          break;
      }
    }
  }

  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }

    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.EOF;
  }

  Token _peek() {
    return _tokens[_current];
  }

  Token _previous() {
    return _tokens[_current - 1];
  }
}

class ParseError implements Exception {}
