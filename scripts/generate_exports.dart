// ignore_for_file: avoid_print
import 'dart:io';

const _barrelFile = 'lib/svgl_flutter.dart';

Future<void> main() async {
  const barrel = '''// GENERATED CODE - DO NOT MODIFY BY HAND
// Run `dart run scripts/generate_exports.dart` to regenerate.

export 'src/svgl.dart';
export 'src/svgl_logos.dart';
export 'src/urls.dart';
''';
  File(_barrelFile).writeAsStringSync(barrel);
  print('Generated $_barrelFile.');
}
