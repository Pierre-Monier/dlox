import 'token.dart';
import 'lox.dart';
import 'token_type.dart';

class Scanner {
  final String _source;
  final List<Token> _tokens = [];
  var _start = 0;
  var _current = 0;
  var _line = 1;

  Scanner(this._source);

  static final _keywords = {
    'and': TokenType.AND,
    'class': TokenType.CLASS,
    'else': TokenType.ELSE,
    'false': TokenType.FALSE,
    'for': TokenType.FOR,
    'fun': TokenType.FUN,
    'if': TokenType.IF,
    'nil': TokenType.NIL,
    'or': TokenType.OR,
    'print': TokenType.PRINT,
    'return': TokenType.RETURN,
    'super': TokenType.SUPER,
    'this': TokenType.THIS,
    'true': TokenType.TRUE,
    'var': TokenType.VAR,
    'while': TokenType.WHILE,
  };

  List<Token> scanTokens() {
    while (!_isAtEnd) {
      _start = _current;
      _scanToken();
    }

    _tokens.add(Token(TokenType.EOF, '', null, _line));
    return _tokens;
  }

  _scanToken() {
    final c = _advance();
    switch (c) {
      case '(':
        _addToken(TokenType.LEFT_PAREN, null);
        break;
      case ')':
        _addToken(TokenType.RIGHT_PAREN, null);
        break;
      case '{':
        _addToken(TokenType.LEFT_BRACE, null);
        break;
      case '}':
        _addToken(TokenType.RIGHT_BRACE, null);
        break;
      case ',':
        _addToken(TokenType.COMMA, null);
        break;
      case '.':
        _addToken(TokenType.DOT, null);
        break;
      case '-':
        _addToken(TokenType.MINUS, null);
        break;
      case '+':
        _addToken(TokenType.PLUS, null);
        break;
      case ';':
        _addToken(TokenType.SEMICOLON, null);
        break;
      case '*':
        _addToken(TokenType.STAR, null);
        break;
      case '!':
        _addToken(_match('=') ? TokenType.BANG_EQUAL : TokenType.BANG, null);
        break;
      case '=':
        _addToken(_match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL, null);
        break;
      case '<':
        _addToken(_match('=') ? TokenType.LESS_EQUAL : TokenType.LESS, null);
        break;
      case '>':
        _addToken(
            _match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER, null);
        break;
      case '?':
        _addToken(TokenType.QUESTION_MARK, null);
        break;
      case ':':
        _addToken(TokenType.COLON, null);
        break;
      case '/':
        if (_match('/')) {
          // A comment goes until the end of the line.
          while (_peek() != '\n' && !_isAtEnd) _advance();
        } else if (_match('*')) {
          // A block comment goes until the closing "*/".
          while (!_isAtEnd) {
            if (_peek() == '*' && _peekNext() == '/') {
              _advance();
              _advance();
              break;
            }

            if (_currentChar() == '\n') _line++;
            _advance();
          }
        } else {
          _addToken(TokenType.SLASH, null);
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;
      case '\n':
        _line++;
        break;
      case '"':
        _string();
        break;
      default:
        if (_isDigit(c)) {
          _number();
        } else if (_isAlpha(c)) {
          _identifier();
        } else {
          Lox.error(_line, 'Unexpected character.');
        }
        break;
    }
  }

  _string() {
    while (_peek() != '"' && !_isAtEnd) {
      if (_peek() == '\n') _line++;
      _advance();
    }

    if (_isAtEnd) {
      Lox.error(_line, 'Unterminated string.');
      return;
    }

    // The closing ".
    _advance();

    // Trim the surrounding quotes.
    final value = _source.substring(_start + 1, _current - 1);
    _addToken(TokenType.STRING, value);
  }

  _number() {
    while (_isDigit(_peek())) _advance();

    // Look for a fractional part.
    if (_peek() == '.' && _isDigit(_peekNext())) {
      // Consume the "."
      _advance();

      while (_isDigit(_peek())) _advance();
    }

    final value = _source.substring(_start, _current);
    final isDouble = value.contains('.');
    _addToken(
        TokenType.NUMBER, isDouble ? double.parse(value) : int.parse(value));
  }

  _identifier() {
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final text = _source.substring(_start, _current);
    final type = _keywords[text] ?? TokenType.IDENTIFIER;
    _addToken(type, null);
  }

  String _advance() {
    _current++;
    return _currentChar(offset: -1);
  }

  _addToken(TokenType type, Object? literal) {
    final text = _source.substring(_start, _current);
    _tokens.add(Token(type, text, literal, _line));
  }

  _match(String expected) {
    if (_isAtEnd) return false;
    if (_currentChar() != expected) return false;

    _current++;
    return true;
  }

  _peek() {
    if (_isAtEnd) return '';
    return _currentChar();
  }

  _peekNext() {
    if (_current + 1 >= _source.length) return '\0';
    return _currentChar(offset: 1);
  }

  bool _isDigit(String c) => c.compareTo('0') >= 0 && c.compareTo('9') <= 0;

  bool _isAlpha(String c) =>
      (c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
      (c.compareTo('A') >= 0 && c.compareTo('Z') <= 0) ||
      c == '_';

  bool _isAlphaNumeric(String c) {
    return _isAlpha(c) || _isDigit(c);
  }

  bool get _isAtEnd => _current >= _source.length;

  String _currentChar({int? offset}) => _source[_current + (offset ?? 0)];
}
