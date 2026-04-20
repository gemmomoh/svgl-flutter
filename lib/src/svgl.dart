import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a brand SVG logo from the [svgl.app](https://svgl.app) collection.
///
/// Pass a constant from [SvglLogos] as the [logo] parameter:
///
/// ```dart
/// Svgl(logo: SvglLogos.flutter, width: 48)
/// Svgl(logo: SvglLogos.appleDark, width: 32)
/// Svgl(logo: SvglLogos.github)
/// ```
class Svgl extends StatelessWidget {
  const Svgl({
    super.key,
    required this.logo,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
    this.semanticsLabel,
  });

  /// An SVG string from [SvglLogos], e.g. `SvglLogos.flutter`.
  final String logo;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      logo,
      width: width,
      height: height,
      fit: fit,
      colorFilter: colorFilter,
      semanticsLabel: semanticsLabel,
    );
  }
}
