import 'dart:io';

import 'interpreter.dart';
import 'parser.dart';
import 'resolver.dart';
import 'scanner.dart';
import 'token.dart';
import 'token_type.dart';

class Lox {
  static final interpreter = Interpreter();
  static bool hadError = false;
  static bool hadRuntimeError = false;

  static void main(List<String> args) {
    if (args.length > 1) {
      print('Usage: dlox [script]');
      exit(64);
    } else if (args.length == 1) {
      interpreter.repl = false;
      _runFile(args.single);
    } else {
      interpreter.repl = true;
      _runPrompt();
    }
  }

  static _runFile(String path) {
    var file = File(path);
    var source = file.readAsStringSync();
    _run(source);

    if (hadError) exit(65);
    if (hadRuntimeError) exit(70);
  }

  static _runPrompt() {
    while (true) {
      stdout.write('> ');
      var line = stdin.readLineSync();
      if (line == null) break;
      _run(line);
    }
  }

  static _run(String source) {
    final scanner = Scanner(source);
    final tokens = scanner.scanTokens();

    final parser = Parser(tokens);
    final statements = parser.parse();

    if (hadError) return;

    if (statements == null) {
      print('Erro while parsing');
    } else {
      final resolver = Resolver(interpreter);
      resolver.resolves(statements);

      // Stop if there was a resolution error.
      if (hadError) return;

      interpreter.interpret(statements);
    }
  }

  static void runtimeError(RuntimeError error) {
    print('${error.message}\n[line ${error.token.line}]');
    hadRuntimeError = true;
  }

  static error(int line, String message) {
    _report(line, '', message);
  }

  static errorWithToken(Token token, String message) {
    if (token.type == TokenType.EOF) {
      _report(token.line, ' at end', message);
    } else {
      _report(token.line, ' at "${token.lexeme}"', message);
    }
  }

  static _report(int line, String where, String message) {
    print('[line $line] Error$where: $message');
    hadError = true;
  }
}
