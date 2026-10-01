import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/termul_theme.dart';
import 'tui_search_field.dart';

/// One command in [showTuiCommandPalette].
class TuiCommand {
  const TuiCommand({
    required this.id,
    required this.label,
    this.subtitle,
    this.shortcut,
    this.glyph,
    this.group,
  });

  final String id;
  final String label;
  final String? subtitle;

  /// Trailing mono hint (`⌘K`, `ctrl+b`, …).
  final String? shortcut;

  /// Optional leading mark (`▸`, `⚙`, `/`, …).
  final String? glyph;

  /// Optional section header (`NAVIGATION`, `SESSION`, …).
  final String? group;
}

/// Fuzzy-ish filter: every query token must appear in label/subtitle/id.
List<TuiCommand> tuiFilterCommands(List<TuiCommand> commands, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return commands;
  final tokens =
      q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  return commands.where((c) {
    final hay =
        '${c.label} ${c.subtitle ?? ''} ${c.id} ${c.group ?? ''}'.toLowerCase();
    return tokens.every(hay.contains);
  }).toList();
}

/// Opens a centered command palette (⌘K / ctrl+K style).
///
/// Returns the selected [TuiCommand.id], or `null` if dismissed.
Future<String?> showTuiCommandPalette(
  BuildContext context, {
  required List<TuiCommand> commands,
  String hint = 'Type a command…',
  String title = 'commands',
  double maxWidth = 480,
  double maxHeightFraction = 0.55,
}) {
  return showDialog<String>(
    context: context,
    barrierColor:
        TermulThemeData.of(context).palette.text.withValues(alpha: 0.35),
    builder: (ctx) => _TuiCommandPaletteDialog(
      commands: commands,
      hint: hint,
      title: title,
      maxWidth: maxWidth,
      maxHeightFraction: maxHeightFraction,
    ),
  );
}

class _TuiCommandPaletteDialog extends StatefulWidget {
  const _TuiCommandPaletteDialog({
    required this.commands,
    required this.hint,
    required this.title,
    required this.maxWidth,
    required this.maxHeightFraction,
  });

  final List<TuiCommand> commands;
  final String hint;
  final String title;
  final double maxWidth;
  final double maxHeightFraction;

  @override
  State<_TuiCommandPaletteDialog> createState() =>
      _TuiCommandPaletteDialogState();
}

class _TuiCommandPaletteDialogState extends State<_TuiCommandPaletteDialog> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  var _index = 0;

  List<TuiCommand> get _filtered =>
      tuiFilterCommands(widget.commands, _controller.text);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _index = 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _select([int? i]) {
    final list = _filtered;
    if (list.isEmpty) return;
    final pick = list[(i ?? _index).clamp(0, list.length - 1)];
    Navigator.pop(context, pick.id);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final list = _filtered;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (list.isEmpty) return KeyEventResult.handled;
      setState(() => _index = (_index + 1) % list.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (list.isEmpty) return KeyEventResult.handled;
      setState(() => _index = (_index - 1 + list.length) % list.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      _select();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final list = _filtered;
    final maxH = MediaQuery.sizeOf(context).height * widget.maxHeightFraction;

    // Group headers when consecutive items share a group and query is empty.
    String? lastGroup;

    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Dialog(
        backgroundColor: p.panel,
        shape: const RoundedRectangleBorder(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            maxHeight: maxH + 80,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  widget.title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: p.accent,
                        letterSpacing: 0.4,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TuiSearchField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: true,
                  hint: widget.hint,
                  prefixGlyph: '❯',
                  showClear: true,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: list.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No matching commands',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: TermulFonts.mono,
                            fontSize: 12,
                            color: p.dim,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final cmd = list[i];
                          final selected = i == _index;
                          final showGroup = cmd.group != null &&
                              cmd.group != lastGroup &&
                              _controller.text.trim().isEmpty;
                          if (showGroup) lastGroup = cmd.group;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (showGroup)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    10,
                                    16,
                                    4,
                                  ),
                                  child: Text(
                                    cmd.group!.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: TermulFonts.mono,
                                      fontSize: 10,
                                      letterSpacing: 0.4,
                                      color: p.dim,
                                    ),
                                  ),
                                ),
                              Material(
                                color: selected
                                    ? p.selection
                                    : Colors.transparent,
                                child: InkWell(
                                  onTap: () => _select(i),
                                  onHover: (_) => setState(() => _index = i),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        if (cmd.glyph != null) ...[
                                          Text(
                                            cmd.glyph!,
                                            style: TextStyle(
                                              fontFamily: TermulFonts.mono,
                                              fontSize: 13,
                                              color: selected
                                                  ? p.accent
                                                  : p.dim,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cmd.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: TermulFonts.mono,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: p.text,
                                                ),
                                              ),
                                              if (cmd.subtitle != null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  cmd.subtitle!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        TermulFonts.mono,
                                                    fontSize: 11,
                                                    color: p.dim,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (cmd.shortcut != null)
                                          Text(
                                            cmd.shortcut!,
                                            style: TextStyle(
                                              fontFamily: TermulFonts.mono,
                                              fontSize: 11,
                                              color: p.dim,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
