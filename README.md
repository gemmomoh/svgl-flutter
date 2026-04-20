# svgl_flutter

An open-source Flutter package that offers a collection of high-quality brand SVG logos as a simple, typed widget with complete autocomplete support.

Powered by the official [`pheralb/svgl`](https://github.com/pheralb/svgl) repository.

## Features

- Single `Svgl` widget — no class name conflicts
- Typed logo constants via `SvglLogos`
- Light and dark mode variants when available
- Tree-shakable — only logos you use are compiled in

## Installation

```yaml
dependencies:
  svgl_flutter: ^0.0.1
```

Or with the Flutter CLI:

```bash
flutter pub add svgl_flutter
```

## Usage

Visit [svgl.app](https://svgl.app) to browse available logos.

```dart
import 'package:svgl_flutter/svgl_flutter.dart';

// Basic usage
Svgl(logo: SvglLogos.flutter, width: 48)

// Light / dark variants
Svgl(logo: SvglLogos.appleLight, width: 32)
Svgl(logo: SvglLogos.appleDark, width: 32)

// With color filter
Svgl(
  logo: SvglLogos.github,
  width: 24,
  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
)
```

## Ecosystem

- [svgl-react](https://github.com/ridemountainpig/svgl-react) for the React ecosystem.
- [svgl-vue](https://github.com/selemondev/svgl-vue) for the Vue ecosystem.
- [svgl-svelte](https://github.com/selemondev/svgl-svelte) for the Svelte ecosystem.

## License

[MIT](LICENSE) © [Gabriel Momoh](https://github.com/gemmomoh)
