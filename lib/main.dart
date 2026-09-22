import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'screens/add_connection_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/shell_demo_screen.dart';
import 'screens/terminal_screen.dart';
import 'state/termul_controller.dart';
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
  final TermulController _controller = TermulController();
  String _galleryTheme = 'oci';
  bool _shellDemo = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onController);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onController)
      ..dispose();
    super.dispose();
  }

  void _onController() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termul',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _TermulScrollBehavior(),
      theme: TermulTheme.of(TermulPalette.oci),
      darkTheme: TermulTheme.of(TermulPalette.ociDark),
      themeMode: _controller.appThemeMode,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey('${_controller.route}-$_shellDemo'),
          child: _buildRoute(),
        ),
      ),
    );
  }

  Widget _buildRoute() {
    if (_shellDemo) {
      return ShellDemoScreen(onBack: () => setState(() => _shellDemo = false));
    }

    switch (_controller.route) {
      case AppRoute.onboarding:
        return OnboardingScreen(controller: _controller);
      case AppRoute.home:
        return HomeScreen(controller: _controller);
      case AppRoute.addConnection:
        return AddConnectionScreen(controller: _controller);
      case AppRoute.terminal:
        return TerminalScreen(controller: _controller);
      case AppRoute.settings:
        return SettingsScreen(controller: _controller);
      case AppRoute.gallery:
        return GalleryScreen(
          themeName: _galleryTheme,
          onThemeChanged: (name) => setState(() => _galleryTheme = name),
          onOpenShell: () => setState(() => _shellDemo = true),
          onBack: _controller.goHome,
        );
    }
  }
}

/// Enable drag paging on web (mouse / trackpad), not only touch.
class _TermulScrollBehavior extends MaterialScrollBehavior {
  const _TermulScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
