import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/termul_palette.dart';
import '../theme/termul_theme.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({
    super.key,
    required this.themeName,
    required this.onThemeChanged,
    required this.onOpenShell,
  });

  final String themeName;
  final ValueChanged<String> onThemeChanged;
  final VoidCallback onOpenShell;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            themeName: themeName,
            onThemeChanged: onThemeChanged,
            onOpenShell: onOpenShell,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _LeftColumn(palette: p)),
                            const SizedBox(width: 16),
                            Expanded(child: _RightColumn(palette: p)),
                          ],
                        )
                      : Column(
                          children: [
                            _LeftColumn(palette: p),
                            const SizedBox(height: 16),
                            _RightColumn(palette: p),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.themeName,
    required this.onThemeChanged,
    required this.onOpenShell,
  });

  final String themeName;
  final ValueChanged<String> onThemeChanged;
  final VoidCallback onOpenShell;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.sidebar,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Row(
        children: [
          TuiText('termul', tone: TuiTextTone.accent, bold: true, size: 16),
          const SizedBox(width: 10),
          TuiText('component gallery', tone: TuiTextTone.dim, size: 12),
          const Spacer(),
          for (final name in TermulPalette.presets.keys) ...[
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: TuiButton(
                label: name,
                variant: themeName == name
                    ? TuiButtonVariant.primary
                    : TuiButtonVariant.ghost,
                onPressed: () => onThemeChanged(name),
              ),
            ),
          ],
          const SizedBox(width: 10),
          TuiButton(
            label: 'open shell demo',
            prefix: '▸',
            onPressed: onOpenShell,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TuiText('# $title', tone: TuiTextTone.cyan, bold: true, size: 13),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({required this.palette});
  final TermulPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: 'typography',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              TuiText('normal — primary body copy'),
              TuiText('muted — secondary labels', tone: TuiTextTone.muted),
              TuiText('dim — chrome / meta', tone: TuiTextTone.dim),
              TuiText('accent — prompts & focus', tone: TuiTextTone.accent),
              TuiText('green · yellow · red · blue · cyan', tone: TuiTextTone.green),
            ],
          ),
        ),
        _Section(
          title: 'buttons & keys',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              TuiButton(label: 'primary', onPressed: _noop),
              TuiButton(
                label: 'ghost',
                variant: TuiButtonVariant.ghost,
                onPressed: _noop,
              ),
              TuiButton(
                label: 'danger',
                variant: TuiButtonVariant.danger,
                onPressed: _noop,
              ),
              TuiKeyHint(keys: 'ctrl+b', label: 'prefix'),
              TuiKeyHint(keys: 'esc', label: 'interrupt'),
            ],
          ),
        ),
        _Section(
          title: 'status & badges',
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final s in TuiAgentState.values)
                TuiStatusDot(state: s, showLabel: true),
              const TuiBadge(label: 'claude', tone: TuiTextTone.magenta),
              const TuiBadge(label: 'codex', tone: TuiTextTone.blue),
              const TuiBadge(label: 'opencode', tone: TuiTextTone.cyan),
            ],
          ),
        ),
        _Section(
          title: 'prompt input',
          child: TuiInput(
            hint: 'type a command…',
            onSubmitted: (_) {},
          ),
        ),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn({required this.palette});
  final TermulPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Section(
          title: 'pane',
          child: SizedBox(
            height: 220,
            child: TuiPane(
              title: 'claude · working',
              subtitle: '~/Projects/termul · master',
              footer: 'ctx 3% · 31k/1M',
              lines: const [
                TuiLogLine(prefix: '❯', text: 'scaffold the TUI gallery'),
                TuiLogLine(
                  prefix: '●',
                  text: 'Created theme tokens and component kit.',
                  tone: TuiTextTone.green,
                ),
                TuiLogLine(
                  prefix: '●',
                  text: 'Plan:',
                  tone: TuiTextTone.accent,
                ),
                TuiLogLine(text: ' · lib/theme — palettes'),
                TuiLogLine(text: ' · lib/components — reusable TUI widgets'),
                TuiLogLine(text: ' · screens — gallery + shell demo'),
                TuiLogLine(
                  prefix: '⠋',
                  text: 'Baking… (esc to interrupt)',
                  tone: TuiTextTone.yellow,
                ),
              ],
            ),
          ),
        ),
        _Section(
          title: 'ascii mark',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.panel,
              border: Border.all(color: palette.border),
            ),
            child: const TuiAsciiLogo(),
          ),
        ),
        _Section(
          title: 'palette swatches',
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Swatch('bg', palette.bg),
              _Swatch('panel', palette.panel),
              _Swatch('accent', palette.accent),
              _Swatch('green', palette.green),
              _Swatch('yellow', palette.yellow),
              _Swatch('red', palette.red),
              _Swatch('blue', palette.blue),
              _Swatch('cyan', palette.cyan),
              _Swatch('magenta', palette.magenta),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Container(
      width: 88,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 22, color: color),
          const SizedBox(height: 4),
          TuiText(label, size: 10, tone: TuiTextTone.dim),
        ],
      ),
    );
  }
}

void _noop() {}
