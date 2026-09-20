import 'package:flutter/material.dart';

import '../theme/termul_theme.dart';
import 'tui_text.dart';

enum TuiAgentState { working, blocked, done, idle, unknown }

extension TuiAgentStateX on TuiAgentState {
  String get glyph => switch (this) {
        TuiAgentState.working => '●',
        TuiAgentState.blocked => '◉',
        TuiAgentState.done => '●',
        TuiAgentState.idle => '○',
        TuiAgentState.unknown => '·',
      };

  String get label => name;

  TuiTextTone get tone => switch (this) {
        TuiAgentState.working => TuiTextTone.green,
        TuiAgentState.blocked => TuiTextTone.yellow,
        TuiAgentState.done => TuiTextTone.blue,
        TuiAgentState.idle => TuiTextTone.dim,
        TuiAgentState.unknown => TuiTextTone.muted,
      };
}

class TuiStatusDot extends StatelessWidget {
  const TuiStatusDot({super.key, required this.state, this.showLabel = false});

  final TuiAgentState state;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TuiText(state.glyph, tone: state.tone, size: 12, bold: true),
        if (showLabel) ...[
          const SizedBox(width: 6),
          TuiText(state.label, tone: state.tone, size: 11),
        ],
      ],
    );
  }
}

class TuiBadge extends StatelessWidget {
  const TuiBadge({
    super.key,
    required this.label,
    this.tone = TuiTextTone.muted,
  });

  final String label;
  final TuiTextTone tone;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
      ),
      child: TuiText(label, tone: tone, size: 10, bold: true),
    );
  }
}
