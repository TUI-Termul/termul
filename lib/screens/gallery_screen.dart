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
        _GallerySection(
          title: 'TuiSheet',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TuiButton(
                label: 'confirm',
                variant: TuiButtonVariant.ghost,
                onPressed: () async {
                  final ok = await showTuiConfirmSheet(
                    context,
                    title: 'host key',
                    message: 'Trust 10.0.0.12?',
                    detail:
                        'First connection. Match this fingerprint on the server before trusting.',
                    confirmLabel: 'trust',
                    cancelLabel: 'cancel',
                  );
                  if (!context.mounted) return;
                  showTuiToast(
                    context,
                    title: ok == true ? 'Trusted' : 'Cancelled',
                    type: ok == true
                        ? TuiToastType.success
                        : TuiToastType.info,
                  );
                },
              ),
              TuiButton(
                label: 'destructive',
                variant: TuiButtonVariant.ghost,
                onPressed: () => showTuiConfirmSheet(
                  context,
                  title: 'host key',
                  message: 'Host key changed',
                  detail:
                      'Something at this address answers with a different key.',
                  confirmLabel: 'replace key',
                  confirmVariant: TuiButtonVariant.danger,
                ),
              ),
              TuiButton(
                label: 'error',
                variant: TuiButtonVariant.ghost,
                onPressed: () => showTuiErrorSheet(
                  context,
                  title: 'connection',
                  message: 'Connection refused',
                  detail: 'Nothing is listening on port 22.',
                ),
              ),
              TuiButton(
                label: 'loading',
                variant: TuiButtonVariant.ghost,
                onPressed: () async {
                  showTuiLoadingSheet(
                    context,
                    title: 'ssh',
                    message: 'prod-west',
                    loadingLabel: 'Connecting…',
                    isDismissible: true,
                    enableDrag: true,
                  );
                },
              ),
              TuiButton(
                label: 'choices',
                variant: TuiButtonVariant.ghost,
                onPressed: () async {
                  final picked = await showTuiChoiceSheet<String>(
                    context,
                    title: 'tmux',
                    message: 'Attach to session',
                    options: const [
                      (value: 'main', label: 'main', meta: '2 windows'),
                      (value: 'dev', label: 'dev', meta: '1 window · attached'),
                      (value: 'ops', label: 'ops', meta: '4 windows'),
                    ],
                    selected: 'dev',
                  );
                  if (!context.mounted || picked == null) return;
                  showTuiToast(
                    context,
                    title: 'Attached',
                    body: 'tmux session “$picked”',
                    type: TuiToastType.success,
                  );
                },
              ),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiMenu',
          child: Row(
            children: [
              TuiMenuButton<String>(
                entries: const [
                  TuiMenuItem(value: 'attach', label: 'Attach tmux'),
                  TuiMenuItem(value: 'edit', label: 'Edit'),
                  TuiMenuItem(value: 'duplicate', label: 'Duplicate'),
                  TuiMenuDivider(),
                  TuiMenuItem(
                    value: 'delete',
                    label: 'Delete',
                    destructive: true,
                    shortcut: '⌫',
                  ),
                ],
                onSelected: (v) => showTuiToast(
                  context,
                  title: 'Host menu',
                  body: v,
                  type: v == 'delete'
                      ? TuiToastType.warning
                      : TuiToastType.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TuiContextMenuRegion<String>(
                  entries: const [
                    TuiMenuItem(
                      value: 'copy',
                      label: 'Copy',
                      shortcut: '⌘C',
                    ),
                    TuiMenuItem(
                      value: 'paste',
                      label: 'Paste',
                      shortcut: '⌘V',
                    ),
                    TuiMenuDivider(),
                    TuiMenuItem(
                      value: 'link',
                      label: 'Copy link address',
                      enabled: false,
                    ),
                  ],
                  onSelected: (v) => showTuiToast(
                    context,
                    title: 'Context',
                    body: v,
                    type: TuiToastType.success,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: TermulThemeData.of(context).palette.border,
                      ),
                      color: TermulThemeData.of(context).palette.surface,
                    ),
                    child: Text(
                      'Long-press or right-click this pane',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: TermulThemeData.of(context).palette.muted,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiTooltip',
          child: Row(
            children: [
              TuiIconButton(
                icon: '⚙',
                tooltip: 'Settings',
                onPressed: () => showTuiToast(
                  context,
                  title: 'Settings',
                  body: 'Icon button with tooltip',
                ),
              ),
              TuiIconButton(
                icon: '×',
                tooltip: 'Close tab',
                onPressed: () => showTuiToast(
                  context,
                  title: 'Closed',
                  type: TuiToastType.info,
                ),
              ),
              TuiIconButton(
                icon: '＋',
                tooltip: 'New tab',
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              TuiTooltip(
                message: 'Transfers queued',
                child: TuiBadge(label: '3 pending'),
              ),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiProgress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TuiSpinner(label: 'Running query…', size: 14),
              const SizedBox(height: 16),
              const TuiProgress(
                label: 'Uploading notes.md',
                value: 0.42,
              ),
              const SizedBox(height: 12),
              const TuiProgressBar(),
              const SizedBox(height: 12),
              const TuiProgress(
                label: 'Saving',
                error: true,
                errorText: 'Save failed — permission denied',
              ),
              const SizedBox(height: 12),
              const TuiProgressBanner(label: 'Connecting…'),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiTransferRow',
          child: Column(
            children: [
              TuiTransferRow(
                name: 'notes.md',
                direction: TuiTransferDirection.upload,
                status: TuiTransferStatus.running,
                host: 'prod-west',
                doneBytes: 420000,
                totalBytes: 1000000,
                speedBytesPerSec: 82000,
                progress: 0.42,
                onCancel: () => showTuiToast(
                  context,
                  title: 'Cancel',
                  body: 'notes.md',
                ),
              ),
              Divider(
                height: 1,
                color: TermulThemeData.of(context).palette.border,
              ),
              TuiTransferRow(
                name: 'dump.sql.gz',
                direction: TuiTransferDirection.download,
                status: TuiTransferStatus.done,
                host: 'db-1',
                doneBytes: 4800000,
                totalBytes: 4800000,
                speedBytesPerSec: 2100000,
                onOpen: () => showTuiToast(
                  context,
                  title: 'Open',
                  body: 'dump.sql.gz',
                  type: TuiToastType.success,
                ),
              ),
              Divider(
                height: 1,
                color: TermulThemeData.of(context).palette.border,
              ),
              TuiTransferRow(
                name: 'secret.env',
                direction: TuiTransferDirection.download,
                status: TuiTransferStatus.failed,
                host: 'prod-west',
                error: 'permission denied',
                onRetry: () => showTuiToast(
                  context,
                  title: 'Retry',
                  body: 'secret.env',
                  type: TuiToastType.warning,
                ),
              ),
            ],
          ),
        ),
        _GallerySection(
          title: 'TuiDataGrid / TuiJsonTree',
          child: SizedBox(
            height: 320,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: TermulThemeData.of(context).palette.accent,
                    unselectedLabelColor:
                        TermulThemeData.of(context).palette.dim,
                    indicatorColor: TermulThemeData.of(context).palette.accent,
                    labelStyle: const TextStyle(
                      fontFamily: TermulFonts.mono,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                    tabs: const [
                      Tab(text: 'GRID'),
                      Tab(text: 'JSON'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        TuiDataGrid(
                          columns: const [
                            TuiDataGridColumn(id: 'id', label: 'id', width: 72),
                            TuiDataGridColumn(
                              id: 'email',
                              label: 'email',
                              width: 180,
                            ),
                            TuiDataGridColumn(
                              id: 'role',
                              label: 'role',
                              width: 100,
                            ),
                          ],
                          rows: const [
                            TuiDataGridRow(
                              id: '1',
                              cells: [
                                TuiDataGridCell(value: '1'),
                                TuiDataGridCell(value: 'ada@termul.dev'),
                                TuiDataGridCell(value: 'admin', dirty: true),
                              ],
                            ),
                            TuiDataGridRow(
                              id: '2',
                              cells: [
                                TuiDataGridCell(value: '2'),
                                TuiDataGridCell(value: 'lin@termul.dev'),
                                TuiDataGridCell(value: null),
                              ],
                            ),
                            TuiDataGridRow(
                              id: '3',
                              isNew: true,
                              cells: [
                                TuiDataGridCell(value: '3'),
                                TuiDataGridCell(value: 'new@termul.dev'),
                                TuiDataGridCell(value: 'viewer'),
                              ],
                            ),
                            TuiDataGridRow(
                              id: '4',
                              deleted: true,
                              cells: [
                                TuiDataGridCell(value: '4'),
                                TuiDataGridCell(value: 'old@termul.dev'),
                                TuiDataGridCell(value: 'viewer'),
                              ],
                            ),
                          ],
                          onCellTap: (r, c) => showTuiToast(
                            context,
                            title: 'Edit cell',
                            body: 'row $r · col $c',
                          ),
                        ),
                        ListView(
                          padding: const EdgeInsets.only(top: 8),
                          children: [
                            TuiJsonCard(
                              index: 1,
                              data: const {
                                '_id': {r'$oid': '66f1a2'},
                                'email': 'ada@termul.dev',
                                'tags': ['admin', 'beta'],
                                'meta': {
                                  'lastLogin': {r'$date': '2026-09-22'},
                                  'devices': 2,
                                },
                              },
                              onCopy: () => showTuiToast(
                                context,
                                title: 'Copied',
                                type: TuiToastType.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _GallerySection(
          title: 'TuiDiffView',
          child: SizedBox(
            height: 280,
            child: TuiDiffView(
              split: true,
              files: [
                TuiDiffFile(
                  path: 'lib/main.dart',
                  added: 2,
                  removed: 1,
                  language: 'dart',
                  rows: tuiDiffRowsToSplit(
                    tuiDiffRowsFromUnified(
                      '@@ -10,3 +10,4 @@\n'
                      ' void main() {\n'
                      '-  runApp(const App());\n'
                      '+  WidgetsFlutterBinding.ensureInitialized();\n'
                      '+  runApp(const TermulApp());\n'
                      ' }\n',
                    ),
                  ),
                ),
              ],
              onCopyPath: (_) => showTuiToast(
                context,
                title: 'Copied path',
                type: TuiToastType.success,
              ),
            ),
          ),
        ),
        const _GallerySection(
          title: 'TuiCodeEditor / TuiMarkdownPreview',
          child: SizedBox(
            height: 360,
            child: _CodeEditorDemo(),
          ),
        ),
        const _GallerySection(
          title: 'TuiFileTree',
          child: SizedBox(
            height: 320,
            child: _FileTreeDemo(),
          ),
        ),
        const _GallerySection(
          title: 'TuiMagicKey',
          child: SizedBox(
            height: 280,
            child: _MagicKeyDemo(),
          ),
        ),
        const _GallerySection(
          title: 'TuiSplitView / TuiTabGroupChip',
          child: SizedBox(
            height: 280,
            child: _SplitDemo(),
          ),
        ),
        const _GallerySection(
          title: 'TuiChatBubble / TuiToolRow',
          child: SizedBox(
            height: 360,
            child: _ChatDemo(),
          ),
        ),
        const _GallerySection(
          title: 'TuiFilterChips',
          child: _FilterChipDemo(),
        ),
        const _GallerySection(
          title: 'TuiDropdown',
          child: _DropdownDemo(),
        ),
        const _GallerySection(
          title: 'TuiCheckbox',
          child: _CheckboxDemo(),
        ),
        const _GallerySection(
          title: 'TuiSlider / TuiStepper',
          child: _SliderDemo(),
        ),
        const _GallerySection(
          title: 'TuiBrandBadge',
          child: _BrandBadgeDemo(),
        ),
      ],
    );
  }
}

class _FileTreeDemo extends StatefulWidget {
  const _FileTreeDemo();

  @override
  State<_FileTreeDemo> createState() => _FileTreeDemoState();
}

class _FileTreeDemoState extends State<_FileTreeDemo> {
  var _expanded = {'/src'};
  String? _selected = '/src/main.dart';
  var _filtering = false;
  late final _filter = TextEditingController();

  static const _children = <String, List<TuiFileNode>>{
    '/': [
      TuiFileNode(id: '/src', name: 'src', kind: TuiFileKind.folder),
      TuiFileNode(id: '/README.md', name: 'README.md', kind: TuiFileKind.file),
      TuiFileNode(id: '/.env', name: '.env', kind: TuiFileKind.file),
    ],
    '/src': [
      TuiFileNode(id: '/src/main.dart', name: 'main.dart', kind: TuiFileKind.file),
      TuiFileNode(
        id: '/src/lib',
        name: 'lib',
        kind: TuiFileKind.folder,
      ),
      TuiFileNode(
        id: '/src/out',
        name: 'out',
        kind: TuiFileKind.symlink,
      ),
    ],
    '/src/lib': [
      TuiFileNode(
        id: '/src/lib/theme.dart',
        name: 'theme.dart',
        kind: TuiFileKind.file,
      ),
    ],
  };

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _filter.text.trim().toLowerCase();
    var nodes = tuiFileTreeFlatten(
      roots: _children['/']!,
      expanded: _expanded,
      childrenOf: (id) => _children[id] ?? const [],
    );
    if (query.isNotEmpty) {
      nodes = nodes.where((n) => n.name.toLowerCase().contains(query)).toList();
    }

    return TuiFileTree(
      title: 'prod-west',
      rootLabel: 'home',
      nodes: nodes,
      selectedId: _selected,
      filtering: _filtering,
      filterController: _filter,
      onFilterChanged: (_) => setState(() {}),
      onToggleFilter: () => setState(() {
        _filtering = !_filtering;
        if (!_filtering) _filter.clear();
      }),
      showDotfiles: true,
      onToggleDotfiles: () {},
      onSelect: (n) => setState(() => _selected = n.id),
      onToggleExpand: (n) => setState(() {
        if (_expanded.contains(n.id)) {
          _expanded = {..._expanded}..remove(n.id);
        } else {
          _expanded = {..._expanded, n.id};
        }
      }),
      onNewFile: () => showTuiToast(context, title: 'New file'),
      onNewFolder: () => showTuiToast(context, title: 'New folder'),
      onUpload: () => showTuiToast(context, title: 'Upload'),
      onRefresh: () => showTuiToast(context, title: 'Refresh'),
      onCollapseAll: () => setState(() => _expanded = {}),
      onRootPressed: () => showTuiToast(context, title: 'Change root'),
    );
  }
}

class _MagicKeyDemo extends StatelessWidget {
  const _MagicKeyDemo();

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.bg,
        border: Border.all(color: p.border),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Long-press the ⏎ disc for rings · drag to dock.\n'
              'Touch-only — omit on desktop.',
              style: TextStyle(
                fontFamily: TermulFonts.mono,
                fontSize: 11,
                color: p.dim,
                height: 1.45,
              ),
            ),
          ),
          Positioned.fill(
            child: TuiMagicKey(
              initialSpot: const Offset(0.82, 0.72),
              onEmit: (label) => showTuiToast(
                context,
                title: 'Emit $label',
                type: TuiToastType.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitDemo extends StatefulWidget {
  const _SplitDemo();

  @override
  State<_SplitDemo> createState() => _SplitDemoState();
}

class _SplitDemoState extends State<_SplitDemo> {
  late final _group = TuiTabGroup(['shell', 'files'], focused: 'shell');
  late final Map<String, double> _weights = {
    for (final id in _group.ids) id: 1,
  };

  Widget _pane(String title, String body) {
    final p = TermulThemeData.of(context).palette;
    return ColoredBox(
      color: p.panel,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: TermulFonts.mono,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontFamily: TermulFonts.mono,
                fontSize: 11,
                color: p.dim,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 36,
          color: p.sidebar,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              TuiTabGroupChip(
                stacked: _group.stacked,
                active: true,
                onActivate: () {},
                onFlip: () => setState(() => _group.stacked = !_group.stacked),
                onUngroup: () => showTuiToast(context, title: 'Ungroup'),
                children: [
                  for (final id in _group.ids)
                    TuiTabChip(
                      label: id,
                      selected: id == _group.focused,
                      onTap: () => setState(() => _group.focused = id),
                    ),
                ],
              ),
              TuiTabChip(label: 'chat', onTap: () {}),
            ],
          ),
        ),
        Expanded(
          child: TuiSplitView(
            axis: _group.axis,
            focusedId: _group.focused,
            onFocus: (id) => setState(() => _group.focused = id),
            onWeightsChanged: (w) => setState(() {
              _weights
                ..clear()
                ..addAll(w);
            }),
            panes: [
              TuiSplitPane(
                id: 'shell',
                weight: _weights['shell'] ?? 1,
                child: _pane('shell', '❯ ls -la\n❯ git status'),
              ),
              TuiSplitPane(
                id: 'files',
                weight: _weights['files'] ?? 1,
                child: _pane('files', 'src/\nREADME.md'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChatDemo extends StatefulWidget {
  const _ChatDemo();

  @override
  State<_ChatDemo> createState() => _ChatDemoState();
}

class _ChatDemoState extends State<_ChatDemo> {
  String _selected = '1';

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TuiChatSessionList(
          width: 160,
          title: 'Sessions',
          sessions: [
            TuiChatSession(
              id: '0',
              title: 'ship v0.4',
              kind: TuiChatSessionKind.pinned,
              subtitle: '2h ago',
              selected: _selected == '0',
            ),
            TuiChatSession(
              id: '1',
              title: 'fix magic key',
              kind: TuiChatSessionKind.running,
              subtitle: 'live',
              selected: _selected == '1',
            ),
            TuiChatSession(
              id: '2',
              title: 'readme polish',
              kind: TuiChatSessionKind.finished,
              subtitle: 'yesterday',
              selected: _selected == '2',
            ),
          ],
          onSelect: (s) => setState(() => _selected = s.id),
          onNewChat: () => showTuiToast(context, title: 'New chat'),
          onRefresh: () => showTuiToast(context, title: 'Refresh'),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            children: const [
              TuiChatBubble(text: 'Add a split view for tab groups.'),
              TuiToolRow(
                name: 'Read',
                summary: 'lib/components/tui_split.dart',
                status: TuiToolStatus.done,
                input: 'path: lib/components/tui_split.dart',
                result: '… 420 lines',
                initiallyExpanded: false,
              ),
              TuiToolRow(
                name: 'Bash',
                summary: 'flutter test',
                status: TuiToolStatus.running,
              ),
              TuiChatAnswer(
                text:
                    'Wired `TuiSplitView` with a drag grip and focus outline. '
                    'The strip uses `TuiTabGroupChip` for the grouped tabs.',
              ),
              TuiChatBubble(
                text: 'retry the flaky test',
                delivery: TuiChatDelivery.queued,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChipDemo extends StatefulWidget {
  const _FilterChipDemo();

  @override
  State<_FilterChipDemo> createState() => _FilterChipDemoState();
}

class _FilterChipDemoState extends State<_FilterChipDemo> {
  var _kinds = <String>{'table', 'view'};
  var _keyType = <String>{'string'};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TuiFilterLabel('Object type'),
        TuiFilterChips<String>(
          selected: _kinds,
          onChanged: (s) => setState(() => _kinds = s),
          options: const [
            TuiFilterOption(value: 'table', label: 'Tables', count: 42),
            TuiFilterOption(value: 'view', label: 'Views', count: 8),
            TuiFilterOption(value: 'mat', label: 'Materialized', count: 2),
            TuiFilterOption(value: 'foreign', label: 'Foreign', count: 1),
          ],
        ),
        const SizedBox(height: 16),
        const TuiFilterLabel('Key type (exclusive)'),
        TuiFilterChips<String>(
          exclusive: true,
          allowEmpty: true,
          selected: _keyType,
          onChanged: (s) => setState(() => _keyType = s),
          options: const [
            TuiFilterOption(value: 'string', label: 'string'),
            TuiFilterOption(value: 'hash', label: 'hash'),
            TuiFilterOption(value: 'list', label: 'list'),
            TuiFilterOption(value: 'set', label: 'set'),
            TuiFilterOption(value: 'zset', label: 'zset'),
          ],
        ),
      ],
    );
  }
}

class _DropdownDemo extends StatefulWidget {
  const _DropdownDemo();

  @override
  State<_DropdownDemo> createState() => _DropdownDemoState();
}

class _DropdownDemoState extends State<_DropdownDemo> {
  String? _jump = 'bastion';
  String? _dbKind = 'postgres';

  static const _hosts = [
    TuiDropdownOption(
      value: 'bastion',
      label: 'bastion.prod',
      subtitle: '10.0.0.2 · jump',
    ),
    TuiDropdownOption(
      value: 'edge',
      label: 'edge-west',
      subtitle: '10.0.1.8',
    ),
    TuiDropdownOption(
      value: 'db-a',
      label: 'db-a.internal',
      subtitle: 'disabled',
      enabled: false,
    ),
    TuiDropdownOption(value: 'ci', label: 'ci-runner-3'),
    TuiDropdownOption(value: 'staging', label: 'staging-gw'),
    TuiDropdownOption(value: 'lab', label: 'lab-jump'),
    TuiDropdownOption(value: 'vpn', label: 'vpn-gw'),
    TuiDropdownOption(value: 'office', label: 'office-fw'),
    TuiDropdownOption(value: 'spare', label: 'spare-bastion'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TuiDropdown<String>(
          label: 'Jump host',
          value: _jump,
          allowClear: true,
          emptyLabel: 'Direct (no jump)',
          options: _hosts,
          onChanged: (v) => setState(() => _jump = v),
        ),
        const SizedBox(height: 16),
        TuiDropdown<String>(
          label: 'Database',
          value: _dbKind,
          searchable: false,
          options: const [
            TuiDropdownOption(value: 'postgres', label: 'PostgreSQL'),
            TuiDropdownOption(value: 'mysql', label: 'MySQL'),
            TuiDropdownOption(value: 'mongo', label: 'MongoDB'),
            TuiDropdownOption(value: 'redis', label: 'Redis'),
          ],
          onChanged: (v) => setState(() => _dbKind = v),
        ),
        const SizedBox(height: 16),
        TuiDropdown<String>(
          label: 'Port forward host',
          value: null,
          hint: 'Choose a host…',
          errorText: 'Required for local forwards',
          options: const [
            TuiDropdownOption(value: 'a', label: 'prod-west'),
            TuiDropdownOption(value: 'b', label: 'prod-east'),
          ],
          onChanged: null,
          enabled: false,
        ),
      ],
    );
  }
}

class _CheckboxDemo extends StatefulWidget {
  const _CheckboxDemo();

  @override
  State<_CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<_CheckboxDemo> {
  var _status = true;
  var _created = false;
  bool? _all; // indeterminate when null

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TuiCheckbox(
          label: 'Include status filter',
          value: _status,
          onChanged: (v) => setState(() => _status = v ?? false),
        ),
        const SizedBox(height: 12),
        TuiCheckboxRow(
          value: _created,
          onChanged: (v) => setState(() => _created = v ?? false),
          child: Text(
            'created_at  ≥  2026-01-01',
            style: TextStyle(
              fontFamily: TermulFonts.mono,
              fontSize: 12,
              color: p.text,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TuiCheckbox(
          label: 'Select all rows (tristate)',
          value: _all,
          tristate: true,
          onChanged: (v) => setState(() => _all = v),
        ),
        const SizedBox(height: 12),
        const TuiCheckbox(
          label: 'Disabled',
          value: true,
          onChanged: null,
        ),
      ],
    );
  }
}

class _SliderDemo extends StatefulWidget {
  const _SliderDemo();

  @override
  State<_SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<_SliderDemo> {
  var _terminal = 14.0;
  var _editor = 13.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TuiSlider(
          label: 'Terminal font size',
          value: _terminal,
          min: 9,
          max: 24,
          divisions: 15,
          valueLabel: '${_terminal.round()}px',
          onChanged: (v) => setState(() => _terminal = v),
        ),
        const SizedBox(height: 20),
        TuiStepper(
          label: 'Editor text',
          value: _editor,
          min: 9,
          max: 24,
          step: 1,
          valueLabel: '${_editor.round()}px',
          onChanged: (v) => setState(() => _editor = v),
        ),
        const SizedBox(height: 20),
        const TuiSlider(
          label: 'Disabled',
          value: 16,
          min: 9,
          max: 24,
          valueLabel: '16px',
          onChanged: null,
        ),
      ],
    );
  }
}

class _BrandBadgeDemo extends StatelessWidget {
  const _BrandBadgeDemo();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        TuiBrandBadge(
          brand: TuiBrand.ubuntu,
          version: '24.04',
          active: true,
        ),
        TuiBrandBadge(
          brand: TuiBrand.debian,
          version: '12',
        ),
        TuiBrandBadge(
          brand: TuiBrand.macos,
          version: '15.1',
          active: true,
        ),
        TuiBrandBadge(brand: TuiBrand.arch),
        TuiBrandBadge(brand: TuiBrand.postgres, version: '16'),
        TuiBrandBadge(brand: TuiBrand.mongo),
        TuiBrandBadge(brand: TuiBrand.redis, active: true),
        TuiBrandBadge(),
      ],
    );
  }
}

class _CodeEditorDemo extends StatefulWidget {
  const _CodeEditorDemo();

  @override
  State<_CodeEditorDemo> createState() => _CodeEditorDemoState();
}

class _CodeEditorDemoState extends State<_CodeEditorDemo> {
  var _mode = TuiCodeViewMode.source;
  var _findOpen = true;
  late final _find = TextEditingController(text: 'Termul');
  late final _replace = TextEditingController();

  static const _md = '''
# README

Termul file tab — **source** or rendered preview.

```dart
void main() => runApp(const TermulApp());
```

- Line numbers
- Find / replace
- Binary + dirty states

![diagram](assets/flow.png)
''';

  @override
  void dispose() {
    _find.dispose();
    _replace.dispose();
    super.dispose();
  }

  List<TuiCodeLine> _lines(TermulPalette p) {
    final raw = _md.trim().split('\n');
    return [
      for (var i = 0; i < raw.length; i++)
        TuiCodeLine(
          number: i + 1,
          text: raw[i],
          spans: raw[i].startsWith('#')
              ? TextSpan(
                  text: raw[i],
                  style: TextStyle(color: p.accent, fontWeight: FontWeight.w600),
                )
              : raw[i].startsWith('```')
                  ? TextSpan(text: raw[i], style: TextStyle(color: p.cyan))
                  : null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return TuiCodeEditor(
      path: 'docs/README.md',
      subtitle: 'docs',
      dirty: true,
      showModeToggle: true,
      mode: _mode,
      onModeChanged: (m) => setState(() => _mode = m),
      highlightLine: 3,
      findBar: _findOpen
          ? TuiFindBar(
              findController: _find,
              replaceController: _replace,
              replaceMode: true,
              matchLabel: '1/2',
              onPrevious: () {},
              onNext: () {},
              onToggleReplace: () {},
              onClose: () => setState(() => _findOpen = false),
              onReplace: () {},
              onReplaceAll: () {},
            )
          : null,
      lines: _lines(p),
      previewChild: TuiMarkdownPreview(
        blocks: tuiMarkdownBlocksFrom(
          _md,
          onCopyCode: (code, _) => showTuiToast(
            context,
            title: 'Copied',
            body: '${code.length} chars',
            type: TuiToastType.success,
          ),
        ),
      ),
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
