import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/termul_palette.dart';
import '../theme/termul_theme.dart';

enum AppRoute {
  onboarding,
  home,
  addConnection,
  terminal,
  gallery,
  settings,
}

/// Available terminal typefaces (bundled + system fallbacks).
abstract final class TerminalFonts {
  static const jetbrains = TermulFonts.mono;
  static const spaceGrotesk = TermulFonts.display;
  static const systemMono = 'monospace';

  static const options = <String, String>{
    jetbrains: 'JetBrains Mono',
    spaceGrotesk: 'Space Grotesk',
    systemMono: 'System Mono',
  };
}

/// In-memory app state for the mobile agent-runtime flow.
/// SSH connect is simulated for the web UI preview.
class TermulController extends ChangeNotifier {
  AppRoute route = AppRoute.onboarding;
  AppRoute? _returnRoute;
  bool onboardingDone = false;

  // —— Settings ——
  ThemeMode appThemeMode = ThemeMode.light;
  String terminalThemeName = 'mocha';
  double terminalFontSize = 12;
  String terminalFontFamily = TerminalFonts.jetbrains;
  bool notificationsEnabled = true;

  static const terminalFontSizes = <double>[11, 12, 13, 14, 16, 18];

  TermulPalette get terminalPalette =>
      TermulPalette.terminalThemes[terminalThemeName] ?? TermulPalette.mocha;

  final List<SshConnection> connections = [];
  SshConnection? activeConnection;
  bool connecting = false;
  String? connectError;

  final List<TerminalTab> tabs = [];
  int activeTabIndex = 0;

  int _seq = 0;
  String _nextId(String prefix) => '$prefix-${++_seq}';

  void completeOnboarding() {
    onboardingDone = true;
    route = AppRoute.home;
    notifyListeners();
  }

  void goHome() {
    route = AppRoute.home;
    _returnRoute = null;
    activeConnection = null;
    connectError = null;
    tabs.clear();
    activeTabIndex = 0;
    notifyListeners();
  }

  void openAddConnection() {
    route = AppRoute.addConnection;
    connectError = null;
    notifyListeners();
  }

  void openGallery() {
    route = AppRoute.gallery;
    notifyListeners();
  }

  void openSettings() {
    _returnRoute = route == AppRoute.settings ? _returnRoute : route;
    route = AppRoute.settings;
    notifyListeners();
  }

  void closeSettings() {
    final back = _returnRoute;
    _returnRoute = null;
    if (back == AppRoute.terminal && activeConnection != null) {
      route = AppRoute.terminal;
    } else if (back == AppRoute.gallery) {
      route = AppRoute.gallery;
    } else {
      route = AppRoute.home;
    }
    notifyListeners();
  }

  void setAppThemeMode(ThemeMode mode) {
    appThemeMode = mode;
    notifyListeners();
  }

  void setTerminalTheme(String name) {
    if (!TermulPalette.terminalThemes.containsKey(name)) return;
    terminalThemeName = name;
    notifyListeners();
  }

  void setTerminalFontSize(double size) {
    terminalFontSize = size;
    notifyListeners();
  }

  void setTerminalFontFamily(String family) {
    if (!TerminalFonts.options.containsKey(family)) return;
    terminalFontFamily = family;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    notificationsEnabled = enabled;
    notifyListeners();
  }

  Future<void> addAndConnect({
    required String host,
    required int port,
    required String username,
    required String password,
    String? label,
  }) async {
    final conn = SshConnection(
      id: _nextId('ssh'),
      host: host.trim(),
      port: port,
      username: username.trim(),
      password: password,
      label: label?.trim(),
    );
    connections.insert(0, conn);
    await connect(conn);
  }

  Future<void> connect(SshConnection conn) async {
    connecting = true;
    connectError = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (conn.host.isEmpty || conn.username.isEmpty) {
      connecting = false;
      connectError = 'Host and username are required.';
      notifyListeners();
      return;
    }

    final updated = conn.copyWith(lastConnectedAt: DateTime.now());
    final idx = connections.indexWhere((c) => c.id == conn.id);
    if (idx >= 0) connections[idx] = updated;

    activeConnection = updated;
    tabs
      ..clear()
      ..add(_bootstrapTab(updated, index: 1));
    activeTabIndex = 0;
    connecting = false;
    route = AppRoute.terminal;
    notifyListeners();
  }

  TerminalTab _bootstrapTab(SshConnection conn, {required int index}) {
    return TerminalTab(
      id: _nextId('tab'),
      title: 'tty-$index',
      lines: [
        TerminalLine(
          kind: TerminalLineKind.system,
          text: 'termul · mobile agent runtime',
        ),
        TerminalLine(
          kind: TerminalLineKind.system,
          text: 'ssh ${conn.username}@${conn.endpoint}',
        ),
        const TerminalLine(
          kind: TerminalLineKind.stdout,
          prefix: '●',
          text: 'session attached — agent panes stay alive on this host',
        ),
        const TerminalLine(text: ''),
        const TerminalLine(
          kind: TerminalLineKind.prompt,
          prefix: '❯',
          text: '',
        ),
      ],
    );
  }

  void addTab() {
    final conn = activeConnection;
    if (conn == null) return;
    final n = tabs.length + 1;
    tabs.add(_bootstrapTab(conn, index: n));
    activeTabIndex = tabs.length - 1;
    notifyListeners();
  }

  void selectTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    activeTabIndex = index;
    notifyListeners();
  }

  void closeTab(int index) {
    if (tabs.length <= 1) return;
    tabs.removeAt(index);
    if (activeTabIndex >= tabs.length) {
      activeTabIndex = tabs.length - 1;
    }
    notifyListeners();
  }

  void submitPrompt(String raw) {
    final text = raw.trim();
    if (text.isEmpty || tabs.isEmpty) return;

    final tab = tabs[activeTabIndex];
    final lines = List<TerminalLine>.from(tab.lines)
      ..add(TerminalLine(
        kind: TerminalLineKind.prompt,
        prefix: '❯',
        text: text,
      ))
      ..add(TerminalLine(
        kind: TerminalLineKind.agent,
        prefix: '●',
        text: _mockAgentReply(text),
      ));

    tabs[activeTabIndex] = tab.copyWith(lines: lines);
    notifyListeners();
  }

  String _mockAgentReply(String input) {
    final lower = input.toLowerCase();
    if (lower.startsWith('ssh') || lower.contains('connect')) {
      return 'Already attached to ${activeConnection?.displayName}. Open a new tab for another pane.';
    }
    if (lower == 'help') {
      return 'Try: status · ls agents · clear — or describe a coding task.';
    }
    if (lower == 'status') {
      return 'connected · ${tabs.length} tab(s) · host ${activeConnection?.endpoint}';
    }
    return 'queued for agent · “$input” — (preview UI; wire real PTY/SSH next)';
  }

  void removeConnection(String id) {
    connections.removeWhere((c) => c.id == id);
    if (activeConnection?.id == id) {
      goHome();
      return;
    }
    notifyListeners();
  }
}
