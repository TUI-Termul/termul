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
    this.onBack,
  });

  final String themeName;
  final ValueChanged<String> onThemeChanged;
  final VoidCallback onOpenShell;
  final VoidCallback? onBack;

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
            onBack: onBack,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _LeftColumn()),
                                const SizedBox(width: 48),
                                Expanded(child: _RightColumn(palette: p)),
                              ],
                            )
                          : Column(
                              children: [
                                _LeftColumn(),
                                const SizedBox(height: 32),
                                _RightColumn(palette: p),
                              ],
                            ),
                    ),
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
    this.onBack,
  });

  final String themeName;
  final ValueChanged<String> onThemeChanged;
  final VoidCallback onOpenShell;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final mono = Theme.of(context).textTheme.labelSmall!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: p.bg,
        border: Border(bottom: BorderSide(color: p.border)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onBack != null) ...[
                GestureDetector(
                  onTap: onBack,
                  child: Text(
                    '← BACK',
                    style: mono.copyWith(color: p.dim, letterSpacing: 0.4),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Container(width: 10, height: 10, color: p.deep),
              const SizedBox(width: 10),
              Text(
                'TERMUL INC.',
                style: mono.copyWith(
                  color: p.deep,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'COMPONENT GALLERY',
                style: mono.copyWith(
                  color: p.dim,
                  letterSpacing: 0.4,
                  height: 1,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final name in TermulPalette.presets.keys)
                TuiButton(
                  label: name,
                  variant: themeName == name
                      ? TuiButtonVariant.primary
                      : TuiButtonVariant.ghost,
                  onPressed: () => onThemeChanged(name),
                ),
              TuiButton(
                label: 'shell demo',
                prefix: '▸',
                onPressed: onOpenShell,
              ),
            ],
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
    final p = TermulThemeData.of(context).palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: p.accent,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 6),
          Container(height: 1, color: p.border),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn();

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final display = Theme.of(context).textTheme.displayMedium!;
    final title = Theme.of(context).textTheme.titleMedium!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Termul',
          style: display.copyWith(color: p.accent),
        ),
        const SizedBox(height: 8),
        Text(
          'TUI component kit on an architectural broadsheet.',
          style: title.copyWith(color: p.text),
        ),
        const SizedBox(height: 36),
        _Section(
          title: 'typography',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              TuiText('normal — primary body copy'),
              TuiText('muted — secondary labels', tone: TuiTextTone.muted),
              TuiText('dim — chrome / meta', tone: TuiTextTone.dim),
              TuiText('accent — indigo strike', tone: TuiTextTone.accent),
            ],
          ),
        ),
        _Section(
          title: 'buttons & keys',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              TuiButton(label: 'menu', onPressed: _noop),
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
              const TuiBadge(label: 'claude', tone: TuiTextTone.accent),
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
    final display = Theme.of(context).textTheme.displayMedium!;
    final caption = Theme.of(context).textTheme.labelSmall!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (palette.isLight) ...[
          Container(
            width: double.infinity,
            color: palette.accent,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Indigo\nStrike',
                  style: display.copyWith(color: palette.bg),
                ),
                const SizedBox(height: 16),
                Text(
                  'FULL-BLEED SECTION — THE SINGULAR CHROMATIC VOICE.',
                  style: caption.copyWith(
                    color: palette.bg,
                    letterSpacing: 0.4,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
        ],
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
            padding: const EdgeInsets.all(16),
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
              _Swatch('bone', palette.bg),
              _Swatch('paper', palette.panel),
              _Swatch('indigo', palette.accent),
              _Swatch('deep', palette.deep),
              _Swatch('ink', palette.text),
              _Swatch('dim', palette.dim),
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
