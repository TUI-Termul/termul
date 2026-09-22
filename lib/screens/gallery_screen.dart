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

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TuiSectionLabel(title),
          const SizedBox(height: 6),
          const TuiDivider(),
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
        Text('Termul', style: display.copyWith(color: p.accent)),
        const SizedBox(height: 8),
        Text(
          'TUI component kit — bone paper + indigo accent.',
          style: title.copyWith(color: p.text),
        ),
        const SizedBox(height: 36),
        _GallerySection(
          title: 'TuiText',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              TuiText('normal — primary body copy'),
              TuiText('muted — secondary labels', tone: TuiTextTone.muted),
              TuiText('dim — chrome / meta', tone: TuiTextTone.dim),
              TuiText('accent — indigo', tone: TuiTextTone.accent),
              TuiText('green — success / working', tone: TuiTextTone.green),
              TuiText('yellow — blocked / warn', tone: TuiTextTone.yellow),
              TuiText('red — error', tone: TuiTextTone.red),
              TuiText('blue · cyan · magenta', tone: TuiTextTone.blue),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiButton · TuiKeyHint',
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
              TuiButton(label: 'disabled', onPressed: null),
              TuiKeyHint(keys: 'ctrl+b', label: 'prefix'),
              TuiKeyHint(keys: 'esc', label: 'interrupt'),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiBadge · TuiStatusDot · TuiCountBadge',
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final s in TuiAgentState.values)
                TuiStatusDot(state: s, showLabel: true),
              const TuiBadge(label: 'claude', tone: TuiTextTone.accent),
              const TuiBadge(label: 'codex', tone: TuiTextTone.blue),
              const TuiCountBadge(count: 3),
              const TuiCountBadge(count: 120, max: 99),
            ],
          ),
        ),
        const _FormDemos(),
        const _ChoiceDemos(),
      ],
    );
  }
}

class _FormDemos extends StatefulWidget {
  const _FormDemos();

  @override
  State<_FormDemos> createState() => _FormDemosState();
}

class _FormDemosState extends State<_FormDemos> {
  final _field = TextEditingController(text: 'user@host');

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GallerySection(
          title: 'TuiField',
          child: TuiField(
            label: 'username',
            controller: _field,
            hint: 'root',
          ),
        ),
        _GallerySection(
          title: 'TuiInput',
          child: TuiInput(
            hint: 'type a command…',
            onSubmitted: (_) {},
          ),
        ),
      ],
    );
  }
}

class _ChoiceDemos extends StatefulWidget {
  const _ChoiceDemos();

  @override
  State<_ChoiceDemos> createState() => _ChoiceDemosState();
}

class _ChoiceDemosState extends State<_ChoiceDemos> {
  int _plan = 0;
  bool _alerts = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GallerySection(
          title: 'TuiSelect',
          child: TuiSelect<int>(
            value: _plan,
            onChanged: (v) => setState(() => _plan = v),
            options: const [
              (0, 'FREE'),
              (1, 'PRO'),
              (2, 'TEAM'),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiSwitch',
          child: TuiSwitch(
            label: 'Agent alerts',
            hint: 'PUSH WHEN BLOCKED OR DONE',
            value: _alerts,
            onChanged: (v) => setState(() => _alerts = v),
          ),
        ),
        _GallerySection(
          title: 'TuiDialog',
          child: Align(
            alignment: Alignment.centerLeft,
            child: TuiButton(
              label: 'open confirm',
              prefix: '?',
              onPressed: () async {
                final ok = await showTuiConfirmDialog(
                  context,
                  title: 'discard draft',
                  message: 'Leave without saving?',
                  detail: 'Your pane layout will reset to defaults.',
                  confirmLabel: 'discard',
                  confirmVariant: TuiButtonVariant.danger,
                );
                if (!context.mounted) return;
                showTuiToast(
                  context,
                  title: ok ? 'Discarded' : 'Kept editing',
                  type: ok ? TuiToastType.warning : TuiToastType.info,
                );
              },
            ),
          ),
        ),
        _GallerySection(
          title: 'TuiToast',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TuiButton(
                label: 'info',
                variant: TuiButtonVariant.ghost,
                onPressed: () => showTuiToast(
                  context,
                  title: 'Session attached',
                  body: 'Agent panes stay alive on this host.',
                ),
              ),
              TuiButton(
                label: 'success',
                variant: TuiButtonVariant.ghost,
                onPressed: () => showTuiToast(
                  context,
                  title: 'Copied',
                  type: TuiToastType.success,
                ),
              ),
              TuiButton(
                label: 'warning',
                variant: TuiButtonVariant.ghost,
                onPressed: () => showTuiToast(
                  context,
                  title: 'Host key changed',
                  body: 'Verify the fingerprint before trusting.',
                  type: TuiToastType.warning,
                  action: TuiToastAction(
                    label: 'Settings',
                    onPressed: () {},
                  ),
                ),
              ),
              TuiButton(
                label: 'error',
                variant: TuiButtonVariant.ghost,
                onPressed: () => showTuiToast(
                  context,
                  title: 'Connection refused',
                  body: 'Nothing is listening on port 22.',
                  type: TuiToastType.error,
                  action: TuiToastAction(
                    label: 'Retry',
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn({required this.palette});
  final TermulPalette palette;

  static const _workspaces = [
    TuiWorkspace(
      name: 'termul',
      branch: 'master',
      agents: [
        TuiAgentRow(name: 'termul', state: TuiAgentState.working, runtime: 'claude'),
        TuiAgentRow(name: 'explore', state: TuiAgentState.idle, runtime: 'opencode'),
      ],
    ),
    TuiWorkspace(
      name: 'web-dashboard',
      branch: 'feat/charts',
      agents: [
        TuiAgentRow(
          name: 'web-dashboard',
          state: TuiAgentState.blocked,
          runtime: 'claude',
        ),
      ],
    ),
  ];

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
                  'Indigo\nAccent',
                  style: display.copyWith(color: palette.bg),
                ),
                const SizedBox(height: 16),
                Text(
                  'FULL-BLEED SECTION — ACCENT SURFACE.',
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
        const _ShellDemos(workspaces: _workspaces),
        _GallerySection(
          title: 'TuiPane · TuiAsciiLogo',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
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
                      prefix: '⠋',
                      text: 'Baking… (esc to interrupt)',
                      tone: TuiTextTone.yellow,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.panel,
                  border: Border.all(color: palette.border),
                ),
                child: const TuiAsciiLogo(),
              ),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiBox',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TuiBox(
                expanded: false,
                title: 'snapshot',
                footer: 'read-only',
                padding: const EdgeInsets.all(12),
                child: const TuiText(
                  'Box-drawing frame for nested panels.',
                  tone: TuiTextTone.muted,
                  size: 12,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: TuiBox(
                  title: 'scroll body',
                  child: const SingleChildScrollView(
                    child: TuiText(
                      'Expanded TuiBox fills remaining height inside a bounded parent.',
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const _KeyboardDemo(),
        _GallerySection(
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

class _ShellDemos extends StatefulWidget {
  const _ShellDemos({required this.workspaces});

  final List<TuiWorkspace> workspaces;

  @override
  State<_ShellDemos> createState() => _ShellDemosState();
}

class _ShellDemosState extends State<_ShellDemos> {
  int _tab = 0;
  int _ws = 0;
  int _agent = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GallerySection(
          title: 'TuiTabs',
          child: TuiTabs(
            tabs: const ['termul', 'explore', 'logs'],
            index: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
        ),
        _GallerySection(
          title: 'TuiSidebar',
          child: SizedBox(
            height: 260,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TuiSidebar(
                  workspaces: widget.workspaces,
                  selectedWorkspace: _ws,
                  selectedAgent: _agent,
                  onSelectWorkspace: (i) => setState(() {
                    _ws = i;
                    _agent = -1;
                  }),
                  onSelectAgent: (i) => setState(() => _agent = i),
                  width: 200,
                ),
                Expanded(
                  child: Container(
                    color: TermulThemeData.of(context).palette.panel,
                    alignment: Alignment.center,
                    child: TuiText(
                      'pane ${_tab + 1}',
                      tone: TuiTextTone.dim,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyboardDemo extends StatefulWidget {
  const _KeyboardDemo();

  @override
  State<_KeyboardDemo> createState() => _KeyboardDemoState();
}

class _KeyboardDemoState extends State<_KeyboardDemo> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _GallerySection(
      title: 'TuiTerminalKeyboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TuiInput(
            controller: _controller,
            hint: 'custom keyboard…',
            useCustomKeyboard: true,
          ),
          TuiTerminalKeyboard(
            controller: _controller,
            onEnter: () {},
          ),
        ],
      ),
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
