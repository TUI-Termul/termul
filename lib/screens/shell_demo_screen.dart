import 'package:flutter/material.dart';

import '../components/components.dart';
import '../theme/termul_theme.dart';

class ShellDemoScreen extends StatefulWidget {
  const ShellDemoScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ShellDemoScreen> createState() => _ShellDemoScreenState();
}

class _ShellDemoScreenState extends State<ShellDemoScreen> {
  int _workspace = 0;
  int _agent = 0;
  int _tab = 0;
  final _input = TextEditingController();
  final _history = <TuiLogLine>[
    const TuiLogLine(text: TuiAsciiLogo.mark, tone: TuiTextTone.accent),
    const TuiLogLine(
      text: 'Termul v0.1 · Flutter TUI kit · web preview',
      tone: TuiTextTone.muted,
    ),
    const TuiLogLine(text: ''),
    const TuiLogLine(prefix: '❯', text: 'show agents across spaces'),
    const TuiLogLine(
      prefix: '●',
      text: 'Sidebar lists workspaces; click an agent to focus its pane.',
      tone: TuiTextTone.green,
    ),
  ];

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
      branch: 'feat/usage-charts',
      agents: [
        TuiAgentRow(
          name: 'web-dashboard',
          state: TuiAgentState.blocked,
          runtime: 'claude',
        ),
      ],
    ),
    TuiWorkspace(
      name: 'data-pipeline',
      branch: 'backfill/events-v2',
      agents: [
        TuiAgentRow(
          name: 'data-pipeline',
          state: TuiAgentState.done,
          runtime: 'codex',
        ),
      ],
    ),
  ];

  void _submit(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    setState(() {
      _history.add(TuiLogLine(prefix: '❯', text: text));
      _history.add(
        TuiLogLine(
          prefix: '●',
          text: 'echo: $text',
          tone: TuiTextTone.green,
        ),
      );
      _input.clear();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    final ws = _workspaces[_workspace];
    final agent = ws.agents[_agent.clamp(0, ws.agents.length - 1)];
    final narrow = MediaQuery.sizeOf(context).width < 800;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: p.sidebar,
              border: Border(bottom: BorderSide(color: p.border)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: const TuiText('← gallery', tone: TuiTextTone.dim, size: 12),
                ),
                const SizedBox(width: 16),
                TuiText('termul shell', tone: TuiTextTone.accent, bold: true),
                const Spacer(),
                TuiText(
                  '${ws.name} › ${agent.name}',
                  tone: TuiTextTone.muted,
                  size: 11,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (!narrow)
                  TuiSidebar(
                    workspaces: _workspaces,
                    selectedWorkspace: _workspace,
                    selectedAgent: _agent,
                    onSelectWorkspace: (i) => setState(() {
                      _workspace = i;
                      _agent = 0;
                    }),
                    onSelectAgent: (i) => setState(() => _agent = i),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      TuiTabs(
                        tabs: const ['agents', 'logs', 'server'],
                        index: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TuiPane(
                            title: '${agent.name} · ${agent.state.label}',
                            subtitle: '~/${ws.name} · ${ws.branch}',
                            footer: 'runtime ${agent.runtime} · tab ${_tabName()}',
                            lines: _history,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: TuiInput(
                          controller: _input,
                          hint: 'send to focused pane…',
                          onSubmitted: _submit,
                          autofocus: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: p.sidebar,
              border: Border(top: BorderSide(color: p.border)),
            ),
            child: const Row(
              children: [
                TuiKeyHint(keys: '↵', label: 'submit'),
                SizedBox(width: 14),
                TuiKeyHint(keys: 'tab', label: 'cycle'),
                SizedBox(width: 14),
                TuiKeyHint(keys: 'ctrl+b', label: 'prefix'),
                Spacer(),
                TuiText('herdr-style layout · demo only', tone: TuiTextTone.dim, size: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tabName() => const ['agents', 'logs', 'server'][_tab];
}
