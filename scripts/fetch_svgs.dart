// ignore_for_file: avoid_print
import 'dart:io';
import 'package:http/http.dart' as http;

const _svgsUrl =
    'https://raw.githubusercontent.com/pheralb/svgl/main/src/data/svgs.ts';
const _iconsFile = 'lib/src/svgl_logos.dart';
const _urlsFile = 'lib/src/urls.dart';
const _userAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> main() async {
  // Remove legacy individual widget files if present.
  final oldDir = Directory('lib/src/svgs');
  if (oldDir.existsSync()) {
    oldDir.deleteSync(recursive: true);
    print('Removed old lib/src/svgs/ directory.');
  }

  // Remove legacy svgs_data.dart if present.
  final oldData = File('lib/src/svgs_data.dart');
  if (oldData.existsSync()) {
    oldData.deleteSync();
    print('Removed old lib/src/svgs_data.dart.');
  }

  print('Fetching SVG data from pheralb/svgl...');
  final svgs = await _fetchSvgData();
  print('Found ${svgs.length} SVG entries.\n');

  // fieldName → SVG string content (for SvglIcons class).
  final icons = <String, String>{};
  // fieldName → brand URL (for urls.dart).
  final urls = <String, String>{};
  // Track used field names to handle duplicates.
  final usedNames = <String>{};

  for (final svg in svgs) {
    final title = svg['title'] as String;
    final rawCategory = svg['category'];
    final category = rawCategory is List
        ? (rawCategory.first as String)
        : rawCategory as String;
    final url = (svg['url'] as String?) ?? '';
    final route = svg['route'];

    final Map<String, String> routes;
    if (route is String) {
      routes = {'default': route};
    } else if (route is Map) {
      routes = route.cast<String, String>();
    } else {
      continue;
    }

    // URL constant — once per logo title.
    String baseFieldName = _toFieldName(title, 'default');
    if (title == 'Arc')
      baseFieldName = _toFieldName('$title $category', 'default');
    if (url.isNotEmpty && !urls.containsKey('${baseFieldName}Url')) {
      urls['${baseFieldName}Url'] = url;
    }

    for (final entry in routes.entries) {
      final variant = entry.key;
      final routePath = entry.value;

      // Mirror svgl-react special cases.
      String effectiveTitle = title;
      if (title == 'JetBrains') {
        effectiveTitle =
            (svg['brandUrl'] != null) ? 'JetBrains Colorful' : 'JetBrains Mono';
      } else if (title == 'CSS (New)') {
        effectiveTitle = 'CSS New';
      } else if (title == 'Arc') {
        effectiveTitle = 'Arc $category';
      }

      String fieldName = _toFieldName(effectiveTitle, variant);

      if (usedNames.contains(fieldName)) {
        fieldName = _toFieldName('$effectiveTitle $category', variant);
      }
      usedNames.add(fieldName);

      final svgUrl =
          'https://raw.githubusercontent.com/pheralb/svgl/refs/heads/main/static$routePath';

      try {
        print('  + $fieldName');
        final content = await _fetchSvgContent(svgUrl);
        icons[fieldName] = content;
      } catch (e) {
        print('  ! Error fetching $fieldName: $e');
      }
    }
  }

  _writeIconsFile(icons);
  _writeUrlsFile(urls);

  print('\nDone — ${icons.length} icons in $_iconsFile');
}

// ---------------------------------------------------------------------------
// File writers
// ---------------------------------------------------------------------------

void _writeIconsFile(Map<String, String> icons) {
  final buf = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Run `dart run scripts/fetch_svgs.dart` to regenerate.')
    ..writeln()
    ..writeln('// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names')
    ..writeln()
    ..writeln('/// SVG string constants for every brand logo in svgl.app.')
    ..writeln('///')
    ..writeln('/// Pass any field to [Svgl]:')
    ..writeln('///')
    ..writeln('/// ```dart')
    ..writeln('/// Svgl(logo: SvglLogos.flutter, width: 48)')
    ..writeln('/// Svgl(logo: SvglLogos.appleDark)')
    ..writeln('/// ```')
    ..writeln('abstract final class SvglLogos {');

  for (final entry in icons.entries) {
    final field = entry.key;
    // Escape ''' sequences that would break raw triple-quoted strings.
    final svg = entry.value.replaceAll("'''", r"\'\'\'");
    buf.writeln("  static const String $field = r'''$svg''';");
    buf.writeln();
  }

  buf.writeln('}');
  File(_iconsFile).writeAsStringSync(buf.toString());
}

void _writeUrlsFile(Map<String, String> urls) {
  final buf = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Run `dart run scripts/fetch_svgs.dart` to regenerate.')
    ..writeln('// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names')
    ..writeln();

  final sorted = urls.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  for (final e in sorted) {
    buf.writeln("const String ${e.key} = '${e.value}';");
  }

  File(_urlsFile).writeAsStringSync(buf.toString());
}

// ---------------------------------------------------------------------------
// Fetch & parse svgs.ts
// ---------------------------------------------------------------------------

Future<List<Map<String, dynamic>>> _fetchSvgData() async {
  final res =
      await http.get(Uri.parse(_svgsUrl), headers: {'User-Agent': _userAgent});
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode} fetching SVG data');
  }

  final arrayMatch =
      RegExp(r'export const svgs[^=]+=\s*(\[[\s\S]*?\]);').firstMatch(res.body);
  if (arrayMatch == null) throw Exception('Could not locate svgs array');

  return _splitTopLevelObjects(arrayMatch.group(1)!)
      .map(_parseTsObject)
      .whereType<Map<String, dynamic>>()
      .toList();
}

List<String> _splitTopLevelObjects(String array) {
  final objects = <String>[];
  var depth = 0;
  var start = -1;
  for (var i = 0; i < array.length; i++) {
    final ch = array[i];
    if (ch == '{') {
      if (depth == 0) start = i;
      depth++;
    } else if (ch == '}') {
      depth--;
      if (depth == 0 && start != -1) {
        objects.add(array.substring(start, i + 1));
        start = -1;
      }
    }
  }
  return objects;
}

Map<String, dynamic>? _parseTsObject(String obj) {
  final title = _extractString(obj, 'title');
  if (title == null) return null;
  return {
    'title': title,
    'url': _extractString(obj, 'url'),
    'brandUrl': _extractString(obj, 'brandUrl'),
    'category': _extractCategoryField(obj),
    'route': _extractRouteField(obj, 'route'),
  };
}

String? _extractString(String obj, String key) =>
    RegExp('$key:\\s*"([^"]*)"').firstMatch(obj)?.group(1);

dynamic _extractCategoryField(String obj) {
  final arrMatch = RegExp(r'category:\s*\[([^\]]*)\]').firstMatch(obj);
  if (arrMatch != null) {
    return RegExp(r'"([^"]*)"')
        .allMatches(arrMatch.group(1)!)
        .map((m) => m.group(1)!)
        .toList();
  }
  return _extractString(obj, 'category') ?? '';
}

dynamic _extractRouteField(String obj, String key) {
  final objMatch =
      RegExp('$key:\\s*\\{([^}]*)\\}', dotAll: true).firstMatch(obj);
  if (objMatch != null) {
    final inner = objMatch.group(1)!;
    final light = RegExp(r'light:\s*"([^"]*)"').firstMatch(inner)?.group(1);
    final dark = RegExp(r'dark:\s*"([^"]*)"').firstMatch(inner)?.group(1);
    final result = <String, String>{};
    if (light != null) result['light'] = light;
    if (dark != null) result['dark'] = dark;
    if (result.isNotEmpty) return result;
  }
  return _extractString(obj, key);
}

// ---------------------------------------------------------------------------
// SVG fetch
// ---------------------------------------------------------------------------

Future<String> _fetchSvgContent(String svgUrl) async {
  final res =
      await http.get(Uri.parse(svgUrl), headers: {'User-Agent': _userAgent});
  if (res.statusCode != 200) {
    throw Exception('HTTP ${res.statusCode}');
  }
  final content = res.body.trim();
  if (content.isEmpty) throw Exception('Empty SVG');
  return _addViewBoxIfMissing(content);
}

String _addViewBoxIfMissing(String svg) {
  if (svg.contains('viewBox')) return svg;
  final wm = RegExp(r'width="([\d.]+)"').firstMatch(svg);
  final hm = RegExp(r'height="([\d.]+)"').firstMatch(svg);
  if (wm != null && hm != null) {
    final w = double.tryParse(wm.group(1)!);
    final h = double.tryParse(hm.group(1)!);
    if (w != null && h != null) {
      return svg.replaceFirst(
          RegExp(r'<svg([^>]*)>'), '<svg\$1 viewBox="0 0 $w $h">');
    }
  }
  return svg;
}

// ---------------------------------------------------------------------------
// Naming helpers
// ---------------------------------------------------------------------------

/// Converts a title + variant to a lowerCamelCase Dart field name.
/// "Amazon Web Services" + "dark" → "amazonWebServicesDark"
/// "Apple" + "light" → "appleLight"
/// "Flutter" + "default" → "flutter"
String _toFieldName(String title, String variant) {
  var s = title;
  s = s.replaceAll('+', 'Plus');
  s = s.replaceAll('#', 'Sharp');
  // Remove content within parentheses, e.g. "Brand (Variant)" -> "Brand"
  s = s.replaceAll(RegExp(r'\(.*?\)'), '');
  s = s.replaceAll('.', '');
  // Split on spaces, hyphens, slashes → word boundaries
  final words = s.split(RegExp(r'[\s\-/]+'));
  final camel = words.indexed.map((e) {
    final (i, word) = e;
    if (word.isEmpty) return '';
    if (i == 0) return word[0].toLowerCase() + word.substring(1);
    return word[0].toUpperCase() + word.substring(1);
  }).join();

  // Remove any remaining non-alphanumeric chars.
  var result = camel.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  // Ensure the identifier is valid (cannot start with a digit).
  if (result.isNotEmpty && RegExp(r'^[0-9]').hasMatch(result)) {
    if (result.startsWith('1')) {
      result = 'one${result.substring(1)}';
    } else {
      result = 'v$result';
    }
  }

  // Append variant suffix.
  if (variant == 'light') result += 'Light';
  if (variant == 'dark') result += 'Dark';

  return result;
}
