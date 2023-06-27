import 'dart:io';

class GenerateAst {
  static void main(List<String> args) {
    if (args.length != 1) {
      print('Usage: generate_ast <output directory>');
      exit(64);
    }

    final outputDir = args.single;
    _defineAst(outputDir, 'Expr', [
      'Ternary  : Expr condition, Expr thenBranch, Expr elseBranch',
      'Binary   : Expr left, Token operator, Expr right',
      'Grouping : Expr expression',
      'Literal  : Object? value',
      'Unary    : Token operator, Expr right',
    ]);
  }

  static void _defineAst(
      String outputDir, String baseName, List<String> types) {
    final path = outputDir + "/" + baseName.toLowerCase() + ".dart";
    final exprFile = File(path);

    final writer = exprFile.openWrite();

    writer.writeln("import 'token.dart';");
    writer.writeln();
    writer.writeln('abstract class $baseName {');
    writer.writeln("  R accept<R>(${baseName}Visitor<R> visitor);");
    writer.writeln("}");

    _defineVisitor(writer: writer, baseName: baseName, types: types);

    for (final type in types) {
      final className = type.split(':')[0].trim();
      final fields = type.split(':')[1].trim();
      _defineType(
          writer: writer,
          baseName: baseName,
          className: className,
          fields: fields);
    }

    writer.close();
  }

  static void _defineType({
    required IOSink writer,
    required String baseName,
    required String className,
    required String fields,
  }) {
    writer.writeln('\n');
    writer.writeln('class $className extends $baseName {');

    final constructorFields =
        fields.split(', ').map((e) => 'this.${e.split(' ')[1]}');

    writer.writeln('  $className(${constructorFields.join(', ')});');

    final fieldList = fields.split(', ');

    for (final field in fieldList) {
      final type = field.split(' ')[0];
      final name = field.split(' ')[1];
      writer.writeln();
      writer.write('  final $type $name;');
    }
    writer.writeln();
    writer.writeln();

    writer.writeln('  @override');
    writer.writeln('  R accept<R>(${baseName}Visitor<R> visitor) {');
    writer.writeln('    return visitor.visit$className$baseName(this);');
    writer.write('  }');
    writer.writeln('\n}');
  }

  static void _defineVisitor({
    required IOSink writer,
    required String baseName,
    required List<String> types,
  }) {
    writer.writeln();
    writer.writeln('abstract interface class ${baseName}Visitor<R> {');

    for (final type in types) {
      final typeName = type.split(':')[0].trim();
      writer.writeln(
          '  R visit$typeName$baseName($typeName ${baseName.toLowerCase()});');
    }

    writer.write('}');
  }
}
