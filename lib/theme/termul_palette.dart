import 'package:flutter/material.dart';

/// Terminal-native color tokens inspired by agent multiplexers like Herdr.
@immutable
class TermulPalette {
  const TermulPalette({
    required this.bg,
    required this.panel,
    required this.sidebar,
    required this.surface,
    required this.border,
    required this.text,
    required this.muted,
    required this.dim,
    required this.accent,
    required this.green,
    required this.yellow,
    required this.red,
    required this.blue,
    required this.cyan,
    required this.magenta,
    required this.selection,
  });

  final Color bg;
  final Color panel;
  final Color sidebar;
  final Color surface;
  final Color border;
  final Color text;
  final Color muted;
  final Color dim;
  final Color accent;
  final Color green;
  final Color yellow;
  final Color red;
  final Color blue;
  final Color cyan;
  final Color magenta;
  final Color selection;

  /// Catppuccin Mocha — default dark TUI look.
  static const mocha = TermulPalette(
    bg: Color(0xFF11111B),
    panel: Color(0xFF1E1E2E),
    sidebar: Color(0xFF181825),
    surface: Color(0xFF313244),
    border: Color(0xFF45475A),
    text: Color(0xFFCDD6F4),
    muted: Color(0xFFA6ADC8),
    dim: Color(0xFF6C7086),
    accent: Color(0xFFA6E3A1),
    green: Color(0xFFA6E3A1),
    yellow: Color(0xFFF9E2AF),
    red: Color(0xFFF38BA8),
    blue: Color(0xFF89B4FA),
    cyan: Color(0xFF94E2D5),
    magenta: Color(0xFFCBA6F7),
    selection: Color(0xFF45475A),
  );

  /// Classic green-on-black CRT terminal.
  static const phosphor = TermulPalette(
    bg: Color(0xFF0A0F0A),
    panel: Color(0xFF0F1A0F),
    sidebar: Color(0xFF0C140C),
    surface: Color(0xFF1A2A1A),
    border: Color(0xFF2A4A2A),
    text: Color(0xFFB8F0B8),
    muted: Color(0xFF7AB87A),
    dim: Color(0xFF4A704A),
    accent: Color(0xFF39FF14),
    green: Color(0xFF39FF14),
    yellow: Color(0xFFD4E84A),
    red: Color(0xFFFF6B6B),
    blue: Color(0xFF6BCBFF),
    cyan: Color(0xFF5CE1E6),
    magenta: Color(0xFFC77DFF),
    selection: Color(0xFF1F3A1F),
  );

  /// Tokyo Night.
  static const tokyoNight = TermulPalette(
    bg: Color(0xFF1A1B26),
    panel: Color(0xFF24283B),
    sidebar: Color(0xFF1F2335),
    surface: Color(0xFF292E42),
    border: Color(0xFF3B4261),
    text: Color(0xFFC0CAF5),
    muted: Color(0xFFA9B1D6),
    dim: Color(0xFF565F89),
    accent: Color(0xFF7AA2F7),
    green: Color(0xFF9ECE6A),
    yellow: Color(0xFFE0AF68),
    red: Color(0xFFF7768E),
    blue: Color(0xFF7AA2F7),
    cyan: Color(0xFF7DCFFF),
    magenta: Color(0xFFBB9AF7),
    selection: Color(0xFF33467C),
  );

  static const presets = <String, TermulPalette>{
    'mocha': mocha,
    'phosphor': phosphor,
    'tokyo-night': tokyoNight,
  };
}
