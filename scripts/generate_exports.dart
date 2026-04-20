// ignore_for_file: avoid_print
import 'dart:io';

const _barrelFile = 'lib/svgl_flutter.dart';

Future<void> main() async {
  const barrel = '''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `dart run scripts/generate_exports.dart` to regenerate.

/// Flutter widget library for brand SVG logos powered by svgl.app.
library svgl_flutter;

export 'src/svgl.dart';
/// Collection of brand SVG logo constants.
export 'src/svgl_logos.dart';
/// Collection of brand website URLs.
export 'src/urls.dart';
''';
  File(_barrelFile).writeAsStringSync(barrel);
  print('Generated $_barrelFile.');
}
