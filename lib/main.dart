import 'package:flutter/material.dart';

import 'screens/gallery_screen.dart';
import 'screens/shell_demo_screen.dart';
import 'theme/termul_palette.dart';
import 'theme/termul_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TermulApp());
}

class TermulApp extends StatefulWidget {
  const TermulApp({super.key});

  @override
  State<TermulApp> createState() => _TermulAppState();
}

class _TermulAppState extends State<TermulApp> {
  String _themeName = 'mocha';
  bool _shell = false;

  TermulPalette get _palette =>
      TermulPalette.presets[_themeName] ?? TermulPalette.mocha;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termul',
      debugShowCheckedModeBanner: false,
      theme: TermulTheme.dark(_palette),
      home: _shell
          ? ShellDemoScreen(onBack: () => setState(() => _shell = false))
          : GalleryScreen(
              themeName: _themeName,
              onThemeChanged: (name) => setState(() => _themeName = name),
              onOpenShell: () => setState(() => _shell = true),
            ),
    );
  }
}
