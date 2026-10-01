import 'package:flutter/material.dart';

import '../components/components.dart';
import '../models/models.dart';
import '../state/termul_controller.dart';
import '../theme/termul_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final TermulController controller;

  @override
  Widget build(BuildContext context) {
    final empty = controller.connections.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HomeHeader(onSettings: controller.openSettings),
            Expanded(
              child: empty
                  ? const _EmptyState()
                  : _ConnectionList(
                      connections: controller.connections,
                      connecting: controller.connecting,
                      onConnect: controller.connect,
                      onRemove: controller.removeConnection,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: _HomeToolbar(
                connecting: controller.connecting,
                onAdd: controller.openAddConnection,
              ),
            ),
            if (controller.connecting)
              const TuiProgressBanner(label: 'Connecting…'),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          const TuiLandingBack(),
          Container(width: 10, height: 10, color: p.deep),
          const SizedBox(width: 10),
          Text(
            'TERMUL',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: p.deep,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
          ),
          const Spacer(),
          _HomeAction(
            tooltip: 'Settings',
            icon: Icons.settings_outlined,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}

/// Add-host control plus the home action icons — always one horizontal row.
class _HomeToolbar extends StatelessWidget {
  const _HomeToolbar({
    required this.connecting,
    required this.onAdd,
  });

  final bool connecting;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    const gap = 6.0;
    final actions = <Widget>[
      TuiButton(
        label: 'add ssh connection',
        prefix: '+',
        onPressed: connecting ? null : onAdd,
      ),
      _HomeAction(
        tooltip: 'Transfers',
        icon: Icons.swap_vert,
        onTap: () => showTuiToast(
          context,
          title: 'Transfers',
          body: 'Preview — wire a transfers pane here.',
        ),
      ),
      _HomeAction(
        tooltip: 'Port forwarding',
        icon: Icons.swap_horiz,
        onTap: () => showTuiToast(
          context,
          title: 'Port forwarding',
          body: 'Preview — wire local / remote forwards here.',
        ),
      ),
      _HomeAction(
        tooltip: 'Logs',
        icon: Icons.history,
        onTap: () => showTuiToast(
          context,
          title: 'Logs',
          body: 'Preview — session and connect logs live here.',
        ),
      ),
      _HomeAction(
        tooltip: 'Known hosts',
        icon: Icons.fingerprint,
        onTap: () => showTuiToast(
          context,
          title: 'Known hosts',
          body: 'Preview — trusted host fingerprints live here.',
        ),
      ),
    ];

    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              actions[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return TuiTooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 36,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: p.border),
            ),
            child: Icon(icon, size: 16, color: p.accent),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const TuiEmptyState(
      layout: TuiEmptyLayout.page,
      title: 'No SSH\nyet',
      body:
          'Add a host to attach terminals and coding agents. You need IP, port, username, and password.',
      calloutLabel: 'FIRST CONNECTION',
      calloutBody:
          'Your agents live on the machine you SSH into — Termul just holds the panes open on mobile.',
    );
  }
}

class _ConnectionList extends StatelessWidget {
  const _ConnectionList({
    required this.connections,
    required this.connecting,
    required this.onConnect,
    required this.onRemove,
  });

  final List<SshConnection> connections;
  final bool connecting;
  final Future<void> Function(SshConnection) onConnect;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final p = TermulThemeData.of(context).palette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      children: [
        Text(
          'Hosts',
          style: Theme.of(context)
              .textTheme
              .displayMedium!
              .copyWith(color: p.accent, fontSize: 36),
        ),
        const SizedBox(height: 8),
        Text(
          '${connections.length} SSH connection${connections.length == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: p.dim,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: p.border),
        const SizedBox(height: 8),
        for (final c in connections) ...[
          _ConnectionRow(
            connection: c,
            enabled: !connecting,
            onTap: () => onConnect(c),
            onRemove: () => onRemove(c.id),
          ),
          Container(height: 1, color: p.border),
        ],
      ],
    );
  }
}

class _ConnectionRow extends StatefulWidget {
  const _ConnectionRow({
    required this.connection,
    required this.enabled,
    required this.onTap,
    required this.onRemove,
  });

  final SshConnection connection;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<_ConnectionRow> createState() => _ConnectionRowState();
}

class _ConnectionRowState extends State<_ConnectionRow> {
  Future<void> _confirmRemove() async {
    if (!widget.enabled) return;
    final name = widget.connection.displayName;

    final confirmed = await showTuiConfirmDialog(
      context,
      title: 'remove host',
      message: 'Remove $name?',
      detail:
          'This connection will be deleted from the list. You can add it again later.',
      confirmLabel: 'remove',
    );

    if (confirmed && mounted) {
      widget.onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.connection;
    final last = c.lastConnectedAt;

    return TuiHostCard(
      title: c.displayName,
      endpoint: c.endpoint,
      status: last != null ? 'last · ${_fmt(last)}' : null,
      verb: 'connect',
      enabled: widget.enabled,
      onTap: widget.onTap,
      trailing: TuiHostCardAction(
        label: 'remove',
        enabled: widget.enabled,
        onTap: widget.enabled ? _confirmRemove : null,
      ),
    );
  }

  String _fmt(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
