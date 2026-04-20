import 'package:flutter/material.dart';
import 'package:svgl_flutter/svgl_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Svgl Flutter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Svgl Flutter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Brand Logos powered by svgl.app',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Svgl(logo: SvglLogos.flutter, width: 64),
                    Text('Flutter'),
                  ],
                ),
                SizedBox(width: 40), 
                Column(
                  children: [
                    Svgl(logo: SvglLogos.github, width: 64),
                    Text('GitHub'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
